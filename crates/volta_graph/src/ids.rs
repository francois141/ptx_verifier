use id_collections::id_type;

/// An event, numbered by its position in the candidate trace.
#[id_type]
pub struct EventId(pub u32);

/// A CTA thread, by its linearized index (`tid.x + tid.y * ntid.x + ...`).
#[id_type]
pub struct ThreadIx(pub u32);

/// A static instruction of the analyzed kernel (the producer's lowered pc).
#[id_type]
pub struct ProgramPoint(pub u32);

/// A memory effect.
#[id_type]
pub struct AccessId(pub u32);

/// A value stored by a write effect.
#[id_type]
pub struct ValueId(pub u32);

/// A synchronization object (a named barrier, an mbarrier lifetime, a collective, ...).
#[id_type]
pub struct SyncObjectId(pub u32);

/// One logical generation of a synchronization object.
#[id_type]
pub struct GenerationId(pub u32);

/// One asynchronous operation.
#[id_type]
pub struct AsyncOpId(pub u32);
