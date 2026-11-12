//! The `.vcdump` on-disk format of `volta compare`: a 12-byte header (magic +
//! version), checked before decoding, then a bincode (fixint little-endian) payload whose ids
//! are validated on load, so a truncated, foreign or corrupt file errors instead of panicking.

use std::io::{self, Write};
use std::path::Path;

use bincode::Options;
use volta_expr::SymbolicOutputs;

/// The reference and optimized kernels' verification conditions, as persisted to `.vcdump`
/// files by `volta compare --dump-vcs` and reloaded by `--from-dump`;
/// the on-disk format is this module's. Each side has the same wire layout as the former
/// `VcSnapshot` (`arena`, then `outputs`), so older dumps still load.
#[derive(serde::Serialize, serde::Deserialize)]
pub struct VcDump {
    pub reference: SymbolicOutputs,
    pub optimized: SymbolicOutputs,
}

impl VcDump {
    /// Validate both sides (see `SymbolicOutputs::validate`).
    pub fn validate(&self) -> Result<(), String> {
        self.reference
            .validate()
            .map_err(|e| format!("reference: {}", e))?;
        self.optimized
            .validate()
            .map_err(|e| format!("optimized: {}", e))
    }
}

const DUMP_MAGIC: &[u8; 8] = b"VOLTAVCD";
/// Dump format version, semver-style: bump `DUMP_MINOR` for backwards-compatible additions,
/// `DUMP_MAJOR` (resetting minor) for breaking changes such as `ExprNode`'s bincode layout.
/// A reader accepts its own major with a minor no newer than its own.
// 2.0: removed the SignExtend/ZeroExtend/Truncate/ToInt ExprNode variants (shifting later
// bincode tags) and replaced FloatConst(f64) with RealConst(Real), exact rationals on the wire.
const DUMP_MAJOR: u16 = 2;
const DUMP_MINOR: u16 = 0;

/// Write `dump` to `path`, creating or truncating the file.
pub fn write_vc_dump(path: &Path, dump: &VcDump) -> io::Result<()> {
    let file = std::fs::File::create(path)?;
    let mut writer = io::BufWriter::new(file);
    write_vc_dump_to(&mut writer, dump)?;
    writer.flush()
}

/// Serialize `dump` (header + payload) into any writer - the exact bytes [`write_vc_dump`]
/// writes - so a caller can hash them through a tee writer without a second GiB-scale
/// copy in memory. Does not flush.
pub fn write_vc_dump_to(writer: &mut impl Write, dump: &VcDump) -> io::Result<()> {
    writer.write_all(DUMP_MAGIC)?;
    writer.write_all(&DUMP_MAJOR.to_le_bytes())?;
    writer.write_all(&DUMP_MINOR.to_le_bytes())?;
    // `serialize_into` uses fixint little-endian; `read_vc_dump` must
    // decode with a matching `with_fixint_encoding()` (bincode's
    // `options()` default is varint, which would not round-trip).
    bincode::serialize_into(writer, dump).map_err(io::Error::other)
}

/// Read a dump written by [`write_vc_dump`], checking the header and
/// validating the decoded contents.
pub fn read_vc_dump(path: &Path) -> io::Result<VcDump> {
    read_vc_dump_bytes(&std::fs::read(path)?)
}

/// Decode a dump from its full file contents (see [`read_vc_dump`]), so a caller can
/// fingerprint the raw bytes before decoding without reading the file twice.
pub fn read_vc_dump_bytes(bytes: &[u8]) -> io::Result<VcDump> {
    if bytes.len() < 12 {
        return Err(io::Error::new(
            io::ErrorKind::InvalidData,
            "not a volta VC dump (file is shorter than the header)",
        ));
    }
    let (header, payload) = bytes.split_at(12);
    if &header[..8] != DUMP_MAGIC {
        return Err(io::Error::new(
            io::ErrorKind::InvalidData,
            "not a volta VC dump (bad magic)",
        ));
    }
    let major = u16::from_le_bytes([header[8], header[9]]);
    let minor = u16::from_le_bytes([header[10], header[11]]);
    if major != DUMP_MAJOR || minor > DUMP_MINOR {
        return Err(io::Error::new(
            io::ErrorKind::InvalidData,
            format!(
                "unsupported dump version {}.{} (this build reads {}.0 through {}.{})",
                major, minor, DUMP_MAJOR, DUMP_MAJOR, DUMP_MINOR
            ),
        ));
    }

    // Cap decode allocations at the payload size, so a crafted length
    // prefix can't make bincode try to allocate (e.g.) a terabyte
    // before it ever reads that many bytes.
    let dump: VcDump = bincode::options()
        .with_fixint_encoding()
        .allow_trailing_bytes()
        .with_limit(payload.len() as u64)
        .deserialize(payload)
        .map_err(io::Error::other)?;
    dump.validate().map_err(|e| {
        io::Error::new(
            io::ErrorKind::InvalidData,
            format!("dump is corrupt or from an incompatible version: {}", e),
        )
    })?;
    Ok(dump)
}

#[cfg(test)]
mod tests {
    use super::*;
    use volta_expr::{ExprArena, ExprId};

    /// A dump reloads to an identical structure and re-serializes bit for bit, including the
    /// `Real`s most at risk on the wire: a non-dyadic rational (1/3), both infinities, the
    /// smallest positive subnormal, and -0.0 (normalized to rational zero).
    #[test]
    fn dump_round_trips() {
        let mut arena = ExprArena::new();
        let x = arena.param_symbol("x");
        let one = arena.int(1);
        let sum = arena.add(x, one);
        let one_f = arena.float_from_f64(1.0).unwrap();
        let three_f = arena.float_from_f64(3.0).unwrap();
        let third = arena.div(one_f, three_f);
        let pos_inf = arena.float_from_f64(f64::INFINITY).unwrap();
        let neg_inf = arena.float_from_f64(f64::NEG_INFINITY).unwrap();
        let subnormal = arena.float_from_f64(f64::from_bits(1)).unwrap();
        let neg_zero = arena.float_from_f64(-0.0).unwrap();
        let specials = [third, pos_inf, neg_inf, subnormal, neg_zero];
        let outputs: Vec<(String, Vec<(u64, ExprId)>)> = vec![(
            "out".to_string(),
            [(0, sum), (1, x)]
                .into_iter()
                .chain(specials.iter().enumerate().map(|(i, &e)| (2 + i as u64, e)))
                .collect(),
        )];
        let dump = VcDump {
            reference: SymbolicOutputs {
                arena: arena.clone(),
                outputs: outputs.clone(),
            },
            optimized: SymbolicOutputs { arena, outputs },
        };

        let dir = std::env::temp_dir();
        let path = dir.join(format!("volta_vc_dump_test_{}.vcdump", std::process::id()));
        let path2 = dir.join(format!(
            "volta_vc_dump_test_rt_{}.vcdump",
            std::process::id()
        ));
        write_vc_dump(&path, &dump).expect("write_vc_dump");
        let loaded = read_vc_dump(&path).expect("read_vc_dump");
        write_vc_dump(&path2, &loaded).expect("write_vc_dump (reloaded)");
        let original_bytes = std::fs::read(&path).expect("read original dump");
        let rewritten_bytes = std::fs::read(&path2).expect("read rewritten dump");
        let _ = std::fs::remove_file(&path);
        let _ = std::fs::remove_file(&path2);

        assert_eq!(
            original_bytes, rewritten_bytes,
            "round-trip must be byte-exact"
        );
        assert_eq!(
            loaded.reference.outputs, dump.reference.outputs,
            "reference footprint survived the round-trip"
        );
        assert_eq!(loaded.optimized.outputs, dump.optimized.outputs);
        for &e in &specials {
            assert_eq!(
                loaded.reference.arena.node(e),
                dump.reference.arena.node(e),
                "special constant survived the round-trip"
            );
        }
    }

    /// `read_vc_dump` on a corrupt file yields the given `InvalidData`
    /// error containing `needle` - never `Ok`, never a panic. (`VcDump`
    /// isn't `Debug`, so we can't use `expect_err`.)
    fn assert_load_rejects(bytes: &[u8], tag: &str, needle: &str) {
        let path =
            std::env::temp_dir().join(format!("volta_vc_dump_{}_{}.bin", tag, std::process::id()));
        std::fs::write(&path, bytes).unwrap();
        let result = read_vc_dump(&path);
        let _ = std::fs::remove_file(&path);
        match result {
            Ok(_) => panic!("{}: corrupt dump was accepted", tag),
            Err(e) => {
                assert_eq!(e.kind(), io::ErrorKind::InvalidData, "{}: error kind", tag);
                assert!(
                    e.to_string().contains(needle),
                    "{}: message {:?} lacks {:?}",
                    tag,
                    e.to_string(),
                    needle
                );
            }
        }
    }

    /// A file without the magic header is rejected cleanly (not decoded).
    #[test]
    fn read_vc_dump_rejects_bad_magic() {
        assert_load_rejects(
            b"not a volta dump at all, definitely",
            "badmagic",
            "not a volta VC dump",
        );
    }

    /// A file shorter than the 12-byte header is rejected with the header
    /// message rather than a raw EOF.
    #[test]
    fn read_vc_dump_rejects_short_file() {
        assert_load_rejects(b"VOLTA", "short", "shorter than the header");
    }

    /// Semver acceptance: same-major newer-minor files (written by a
    /// future backwards-compatible writer) and other-major files are both
    /// refused by this reader with a version message.
    #[test]
    fn read_vc_dump_rejects_unsupported_versions() {
        let mut newer_minor = Vec::from(*DUMP_MAGIC);
        newer_minor.extend_from_slice(&DUMP_MAJOR.to_le_bytes());
        newer_minor.extend_from_slice(&(DUMP_MINOR + 1).to_le_bytes());
        assert_load_rejects(&newer_minor, "newerminor", "unsupported dump version");

        let mut other_major = Vec::from(*DUMP_MAGIC);
        other_major.extend_from_slice(&(DUMP_MAJOR + 1).to_le_bytes());
        other_major.extend_from_slice(&0u16.to_le_bytes());
        assert_load_rejects(&other_major, "othermajor", "unsupported dump version");
    }
}
