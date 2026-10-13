//! The vcs-directory manifest (`<out-dir>/vcs/manifest.json`): pins each dump slug to its
//! benchmark name and an FNV-1a hash of the exact bytes `generate` wrote, which `solve` checks
//! before decoding. Not a source-currency check; assumes a single writer per out-dir.

use std::collections::BTreeMap;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::time::{SystemTime, UNIX_EPOCH};

use anyhow::{Context, Result, bail};
use serde::{Deserialize, Serialize};
use volta_expr::ExprId;

use crate::results::sanitize_name;

/// Manifest filename inside the vcs directory.
pub const MANIFEST_FILE: &str = "manifest.json";

/// Manifest schema version; bump on breaking changes so an old manifest fails
/// loudly instead of misguiding the staleness check (2: `vc_fingerprint`).
pub const MANIFEST_FORMAT: u32 = 2;

/// The whole manifest: dump slug -> what `generate` wrote there.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct VcsManifest {
    pub format: u32,
    pub entries: BTreeMap<String, ManifestEntry>,
}

impl VcsManifest {
    pub fn new() -> Self {
        Self {
            format: MANIFEST_FORMAT,
            entries: BTreeMap::new(),
        }
    }
}

impl Default for VcsManifest {
    fn default() -> Self {
        Self::new()
    }
}

/// One dump's identity: its benchmark, generation time, byte fingerprint, and
/// (informational only) both snapshots' per-array footprint element counts.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ManifestEntry {
    /// The benchmark's display name (slugs are many-to-one, so the full
    /// name pins the slug to one benchmark).
    pub benchmark: String,
    /// When `generate` wrote the dump (unix seconds).
    pub timestamp_unix: u64,
    /// FNV-1a hash of the exact `.vcdump` file bytes `generate` wrote -
    /// the staleness check (see [`check_dump`] and the module docs).
    pub vc_fingerprint: u64,
    /// Reference snapshot: output array name -> written element count.
    /// Informational only; the fingerprint is the check.
    pub reference_elements: BTreeMap<String, u64>,
    /// Optimized snapshot: output array name -> written element count.
    /// Informational only; the fingerprint is the check.
    pub optimized_elements: BTreeMap<String, u64>,
}

/// Where the manifest lives inside a vcs directory.
pub fn manifest_path(vcs_dir: &Path) -> PathBuf {
    vcs_dir.join(MANIFEST_FILE)
}

// =========================================================================
// The dump fingerprint: 64-bit FNV-1a over the dump file's bytes
// =========================================================================

const FNV1A_OFFSET: u64 = 0xcbf2_9ce4_8422_2325;
const FNV1A_PRIME: u64 = 0x0000_0100_0000_01b3;

/// Streaming 64-bit FNV-1a, chosen over `std`'s hashers because the digest
/// must be stable across processes, builds, and Rust releases.
#[derive(Debug, Clone)]
pub struct Fnv1a(u64);

impl Fnv1a {
    pub fn new() -> Self {
        Self(FNV1A_OFFSET)
    }

    pub fn update(&mut self, bytes: &[u8]) {
        for &b in bytes {
            self.0 ^= u64::from(b);
            self.0 = self.0.wrapping_mul(FNV1A_PRIME);
        }
    }

    pub fn finish(&self) -> u64 {
        self.0
    }
}

impl Default for Fnv1a {
    fn default() -> Self {
        Self::new()
    }
}

/// The fingerprint of a complete in-memory byte buffer (the `solve`
/// side: it holds the whole dump file before decoding it).
pub fn fingerprint_bytes(bytes: &[u8]) -> u64 {
    let mut hash = Fnv1a::new();
    hash.update(bytes);
    hash.finish()
}

/// A `Write` tee that FNV-1a-hashes exactly the bytes its inner writer accepts,
/// so `generate` fingerprints the exact file content without a second
/// in-memory copy of a possibly GiB-scale dump.
pub struct HashingWriter<W> {
    inner: W,
    hash: Fnv1a,
}

impl<W: Write> HashingWriter<W> {
    pub fn new(inner: W) -> Self {
        Self {
            inner,
            hash: Fnv1a::new(),
        }
    }

    /// The digest of every byte successfully written so far.
    pub fn fingerprint(&self) -> u64 {
        self.hash.finish()
    }
}

impl<W: Write> Write for HashingWriter<W> {
    fn write(&mut self, buf: &[u8]) -> std::io::Result<usize> {
        let n = self.inner.write(buf)?;
        // Hash only what the inner writer accepted, so the digest equals
        // the file content even across short writes.
        self.hash.update(&buf[..n]);
        Ok(n)
    }

    fn flush(&mut self) -> std::io::Result<()> {
        self.inner.flush()
    }
}

// =========================================================================
// Reading and writing the manifest file
// =========================================================================

/// The format field alone, decoded first so a wrong-format manifest gets
/// the version message even when its entry shape no longer deserializes.
#[derive(Deserialize)]
struct ManifestHeader {
    format: u32,
}

/// Read the manifest: `Ok(None)` when the file does not exist (the caller warns
/// and skips the guard); a present-but-unreadable manifest is a hard error,
/// because a guard that silently degrades is worse than none.
pub fn read_manifest(vcs_dir: &Path) -> Result<Option<VcsManifest>> {
    let path = manifest_path(vcs_dir);
    let text = match std::fs::read_to_string(&path) {
        Err(e) if e.kind() == std::io::ErrorKind::NotFound => return Ok(None),
        other => other.with_context(|| format!("reading {}", path.display()))?,
    };
    let invalid = || {
        format!(
            "{} is not a valid vcs manifest; delete it and re-run \
             `volta-bench generate` to rebuild it",
            path.display()
        )
    };
    let header: ManifestHeader = serde_json::from_str(&text).with_context(invalid)?;
    if header.format != MANIFEST_FORMAT {
        bail!(
            "{} has manifest format {} but this build writes format {}; \
             delete it (and regenerate the dumps) with `volta-bench generate`",
            path.display(),
            header.format,
            MANIFEST_FORMAT
        );
    }
    let manifest: VcsManifest = serde_json::from_str(&text).with_context(invalid)?;
    Ok(Some(manifest))
}

/// Read the manifest, starting a fresh one when none exists (the
/// `generate` read-modify-write entry point). Errors are `read_manifest`'s.
pub fn read_or_new(vcs_dir: &Path) -> Result<VcsManifest> {
    Ok(read_manifest(vcs_dir)?.unwrap_or_default())
}

/// Write the manifest to `<vcs_dir>/manifest.json` (the directory must exist).
/// Atomic via temp file + rename, so no reader or crash sees a torn file;
/// concurrent writers can still lose an update (single writer assumed).
pub fn write_manifest(vcs_dir: &Path, manifest: &VcsManifest) -> Result<()> {
    let path = manifest_path(vcs_dir);
    let text = serde_json::to_string_pretty(manifest).context("serializing the vcs manifest")?;
    // Pid-suffixed so two racing writers cannot corrupt each other's
    // temp file (the rename still lets the later one win whole).
    let tmp = vcs_dir.join(format!("{}.tmp.{}", MANIFEST_FILE, std::process::id()));
    std::fs::write(&tmp, text).with_context(|| format!("writing {}", tmp.display()))?;
    std::fs::rename(&tmp, &path).map_err(|e| {
        let _ = std::fs::remove_file(&tmp);
        anyhow::Error::new(e).context(format!("renaming {} to {}", tmp.display(), path.display()))
    })
}

/// Per-array element counts of one snapshot's output footprint (the
/// `SymbolicOutputs::outputs` shape).
pub fn element_counts(outputs: &[(String, Vec<(u64, ExprId)>)]) -> BTreeMap<String, u64> {
    outputs
        .iter()
        .map(|(name, elems)| (name.clone(), elems.len() as u64))
        .collect()
}

/// Record one just-written dump in the manifest (in memory; the caller writes
/// the file) under its slug, with a now timestamp and the given fingerprint.
pub fn record_dump(
    manifest: &mut VcsManifest,
    benchmark: &str,
    vc_fingerprint: u64,
    reference_outputs: &[(String, Vec<(u64, ExprId)>)],
    optimized_outputs: &[(String, Vec<(u64, ExprId)>)],
) {
    let timestamp_unix = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_secs())
        .unwrap_or(0);
    manifest.entries.insert(
        sanitize_name(benchmark),
        ManifestEntry {
            benchmark: benchmark.to_string(),
            timestamp_unix,
            vc_fingerprint,
            reference_elements: element_counts(reference_outputs),
            optimized_elements: element_counts(optimized_outputs),
        },
    );
}

/// Drop a benchmark's entry (in memory), returning whether one existed. Used
/// after a failed regeneration so a later `solve` fails instead of solving stale VCs.
pub fn remove_entry(manifest: &mut VcsManifest, benchmark: &str) -> bool {
    manifest.entries.remove(&sanitize_name(benchmark)).is_some()
}

/// What checking one dump against the manifest concluded (the error case
/// - disagreement - is the `Err` of [`check_dump`]).
#[derive(Debug, PartialEq, Eq)]
pub enum ManifestCheck {
    /// The manifest has this benchmark's entry and the dump's bytes hash
    /// to its recorded fingerprint.
    Verified,
    /// The manifest has no entry for this benchmark (e.g. a hand-copied
    /// dump); the caller warns and carries on.
    NoEntry,
}

/// The staleness guard: compare a dump's raw-byte hash and benchmark name
/// against the manifest before decoding. Any disagreement (stale, mixed, or
/// clobbered directory) is a hard error telling the user to regenerate.
pub fn check_dump(
    manifest: &VcsManifest,
    benchmark: &str,
    dump_bytes: &[u8],
) -> Result<ManifestCheck> {
    let slug = sanitize_name(benchmark);
    let Some(entry) = manifest.entries.get(&slug) else {
        return Ok(ManifestCheck::NoEntry);
    };
    if entry.benchmark != benchmark {
        bail!(
            "the vcs manifest says dump '{}' belongs to benchmark '{}', not '{}'; \
             the vcs directory is stale or mixed - re-run `volta-bench generate`",
            slug,
            entry.benchmark,
            benchmark
        );
    }
    let found = fingerprint_bytes(dump_bytes);
    if found != entry.vc_fingerprint {
        bail!(
            "dump '{}' does not match the vcs manifest for '{}': its bytes hash to \
             {:#018x}, but generate recorded {:#018x} - the dump differs from the one \
             the last successful generate wrote (stale, mixed, or modified since); \
             re-run `volta-bench generate`",
            slug,
            benchmark,
            found,
            entry.vc_fingerprint
        );
    }
    Ok(ManifestCheck::Verified)
}

#[cfg(test)]
mod tests {
    use id_collections::Id;

    use super::*;

    fn outputs(arrays: &[(&str, u64)]) -> Vec<(String, Vec<(u64, ExprId)>)> {
        arrays
            .iter()
            .map(|&(name, len)| {
                let elems = (0..len)
                    .map(|i| (i, ExprId::from_index(i as u32)))
                    .collect();
                (name.to_string(), elems)
            })
            .collect()
    }

    /// FNV-1a is pinned to its reference constants: the digest must never
    /// change across builds, or every recorded fingerprint would
    /// spuriously mismatch. Vectors from the FNV reference code.
    #[test]
    fn fnv1a_matches_the_reference_vectors() {
        assert_eq!(fingerprint_bytes(b""), 0xcbf2_9ce4_8422_2325);
        assert_eq!(fingerprint_bytes(b"a"), 0xaf63_dc4c_8601_ec8c);
        assert_eq!(fingerprint_bytes(b"foobar"), 0x85944171f73967e8);
    }

    /// The write-side tee and the read-side whole-buffer hash agree byte
    /// for byte - `generate`'s recorded fingerprint must equal what
    /// `solve` computes from `fs::read`, whatever the write chunking.
    #[test]
    fn hashing_writer_agrees_with_fingerprint_bytes() {
        let payload: Vec<u8> = (0u16..1500).map(|i| (i % 251) as u8).collect();
        let mut writer = HashingWriter::new(Vec::new());
        // Deliberately uneven chunks, like a serializer's field-by-field
        // writes.
        for chunk in payload.chunks(7) {
            writer.write_all(chunk).unwrap();
        }
        assert_eq!(writer.fingerprint(), fingerprint_bytes(&payload));
    }

    /// A manifest written by `write_manifest` reads back identical, and a
    /// missing file is `Ok(None)`, not an error.
    #[test]
    fn manifest_round_trips_and_missing_is_none() {
        let dir = std::env::temp_dir().join(format!("volta_manifest_rt_{}", std::process::id()));
        std::fs::create_dir_all(&dir).unwrap();

        assert_eq!(read_manifest(&dir).unwrap(), None);

        let mut manifest = VcsManifest::new();
        record_dump(
            &mut manifest,
            "(Red-1, Red-2)",
            fingerprint_bytes(b"red dump bytes"),
            &outputs(&[("out", 1)]),
            &outputs(&[("out", 1), ("aux", 4)]),
        );
        record_dump(
            &mut manifest,
            "(Attention, FA1)",
            fingerprint_bytes(b"fa1 dump bytes"),
            &outputs(&[("o", 64)]),
            &outputs(&[("o", 64)]),
        );
        write_manifest(&dir, &manifest).unwrap();
        let loaded = read_manifest(&dir).unwrap().expect("manifest exists");
        assert_eq!(loaded, manifest);

        let entry = &loaded.entries["red-1-red-2"];
        assert_eq!(entry.benchmark, "(Red-1, Red-2)");
        assert_eq!(entry.vc_fingerprint, fingerprint_bytes(b"red dump bytes"));
        assert_eq!(entry.reference_elements["out"], 1);
        assert_eq!(entry.optimized_elements["aux"], 4);

        // No temp file lingers after the atomic rename.
        let leftovers: Vec<_> = std::fs::read_dir(&dir)
            .unwrap()
            .map(|e| e.unwrap().file_name())
            .filter(|n| n != MANIFEST_FILE)
            .collect();
        assert!(leftovers.is_empty(), "{leftovers:?}");

        let _ = std::fs::remove_dir_all(&dir);
    }

    /// A corrupt or wrong-format manifest is a hard error naming the file, and
    /// the format check fires even when old entries no longer deserialize.
    #[test]
    fn corrupt_and_wrong_format_manifests_are_rejected() {
        let dir = std::env::temp_dir().join(format!("volta_manifest_bad_{}", std::process::id()));
        std::fs::create_dir_all(&dir).unwrap();

        std::fs::write(manifest_path(&dir), "{ not json").unwrap();
        let err = format!("{:#}", read_manifest(&dir).unwrap_err());
        assert!(err.contains("manifest"), "{err}");
        assert!(err.contains("generate"), "{err}");

        let future = serde_json::json!({ "format": MANIFEST_FORMAT + 1, "entries": {} });
        std::fs::write(manifest_path(&dir), future.to_string()).unwrap();
        let err = format!("{:#}", read_manifest(&dir).unwrap_err());
        assert!(err.contains("format"), "{err}");

        // A format-1 manifest (entries lack `vc_fingerprint`) gets the
        // version message, not a serde field error.
        let v1 = serde_json::json!({
            "format": 1,
            "entries": { "red-1-red-2": {
                "benchmark": "(Red-1, Red-2)",
                "timestamp_unix": 0,
                "reference_elements": {"out": 1},
                "optimized_elements": {"out": 1},
            }},
        });
        std::fs::write(manifest_path(&dir), v1.to_string()).unwrap();
        let err = format!("{:#}", read_manifest(&dir).unwrap_err());
        assert!(err.contains("format 1"), "{err}");
        assert!(err.contains("generate"), "{err}");

        let _ = std::fs::remove_dir_all(&dir);
    }

    /// The staleness guard: matching bytes verify, a missing entry is
    /// only `NoEntry`, and any byte difference - or a slug claimed by
    /// another benchmark - is an error pointing at `generate`.
    #[test]
    fn check_dump_flags_disagreements() {
        let dump_bytes = b"the exact dump bytes generate wrote";
        let reference = outputs(&[("out", 2)]);
        let optimized = outputs(&[("out", 2), ("aux", 3)]);
        let mut manifest = VcsManifest::new();
        record_dump(
            &mut manifest,
            "(Red-1, Red-2)",
            fingerprint_bytes(dump_bytes),
            &reference,
            &optimized,
        );

        assert_eq!(
            check_dump(&manifest, "(Red-1, Red-2)", dump_bytes).unwrap(),
            ManifestCheck::Verified
        );
        assert_eq!(
            check_dump(&manifest, "(Red-1, Red-3)", dump_bytes).unwrap(),
            ManifestCheck::NoEntry
        );

        // Any content drift - here a single flipped byte, the case an
        // id-structure check would miss - fails the hash comparison.
        let mut drifted = dump_bytes.to_vec();
        drifted[10] ^= 1;
        let err = check_dump(&manifest, "(Red-1, Red-2)", &drifted).unwrap_err();
        let msg = format!("{:#}", err);
        assert!(msg.contains("does not match the vcs manifest"), "{msg}");
        assert!(msg.contains("generate"), "{msg}");

        // Truncation that would still decode upstream is also just a
        // byte difference here.
        let err = check_dump(&manifest, "(Red-1, Red-2)", &dump_bytes[..10]).unwrap_err();
        assert!(format!("{:#}", err).contains("generate"));

        // Slugs are many-to-one: the same slug claimed under a different
        // display name is a mixed directory, not a match (checked before
        // the hash, so the message names both benchmarks).
        let err = check_dump(&manifest, "Red 1 Red: 2", dump_bytes).unwrap_err();
        let msg = format!("{:#}", err);
        assert!(msg.contains("(Red-1, Red-2)"), "{msg}");
        assert!(msg.contains("Red 1 Red: 2"), "{msg}");
    }

    /// `remove_entry` drops exactly the named benchmark's entry and
    /// reports whether one existed.
    #[test]
    fn remove_entry_drops_only_the_named_benchmark() {
        let mut manifest = VcsManifest::new();
        let out = outputs(&[("out", 1)]);
        record_dump(&mut manifest, "(Red-1, Red-2)", 1, &out, &out);
        record_dump(&mut manifest, "(Red-1, Red-3)", 2, &out, &out);

        assert!(remove_entry(&mut manifest, "(Red-1, Red-2)"));
        assert!(!remove_entry(&mut manifest, "(Red-1, Red-2)"));
        assert_eq!(manifest.entries.len(), 1);
        assert!(manifest.entries.contains_key("red-1-red-3"));
    }
}
