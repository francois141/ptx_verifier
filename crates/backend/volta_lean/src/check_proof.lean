/-
Volta's acceptance check of a Lean proof, run as `lean --run` with the `challenge` and `proof`
modules on `LEAN_PATH`. It prints one line per statement of `challenge`:

  proved NAME | missing NAME | mistyped NAME | unproved NAME | axioms NAME AXIOM...

The modules are imported at run time, not by this file, so nothing `proof` declares can change
the check.
-/
import Lean

open Lean

/-! ## Axioms -/

/-- The axioms a proof may use; any other one rejects it. -/
def standardAxioms : List Name :=
  [``propext, ``Classical.choice, ``Quot.sound]

/-- The modules whose constants the check looks inside; every other module is trusted. -/
def checkedModules : List Name :=
  [`proof, `challenge]

/-- The axioms found so far for each constant visited. -/
abbrev AxiomCache := NameMap (List Name)

/-- The module that declares `c`, if it was imported. -/
def moduleOf (env : Environment) (c : Name) : Option Name :=
  env.getModuleIdxFor? c |>.bind fun i => env.header.moduleNames[i.toNat]?

/-- Whether `c` is declared by `proof` or `challenge`. -/
def isChecked (env : Environment) (c : Name) : Bool :=
  (moduleOf env c).any checkedModules.contains

/-- `[c]` when `c` is an axiom, else `[]`. -/
def selfIfAxiom (ci : ConstantInfo) (c : Name) : List Name :=
  if ci matches .axiomInfo _ then [c] else []

/-- The constants `ci` refers to: in its type, its value (an opaque one's too) and, for an
inductive type, its constructors. -/
def dependencies (ci : ConstantInfo) : Array Name := Id.run do
  let mut deps := ci.type.getUsedConstants
  if let some value := ci.value? (allowOpaque := true) then
    deps := deps ++ value.getUsedConstants
  if let .inductInfo info := ci then
    deps := deps ++ info.ctors.toArray
  return deps

/-- The axioms reachable from `c`, memoized as `#print axioms` does. A trusted constant is not
looked inside: it contributes only itself, if it is an axiom. -/
partial def axiomsOf (env : Environment) (c : Name) : StateM AxiomCache (List Name) := do
  -- A constant already visited, or still being visited (a cycle), adds nothing new.
  if let some known := (← get).find? c then
    return known
  modify (·.insert c [])

  let some ci := env.find? c
    | return []

  -- A trusted constant: only itself.
  unless isChecked env c do
    let found := selfIfAxiom ci c
    modify (·.insert c found)
    return found

  -- A checked constant: itself and every axiom its dependencies reach, each listed once.
  let mut found := selfIfAxiom ci c
  for dep in dependencies ci do
    for ax in ← axiomsOf env dep do
      unless found.contains ax do
        found := ax :: found
  modify (·.insert c found)
  return found

/-! ## Verdicts -/

/-- The verdict line of the statement `VoltaChallenge.NAME`, proved only by a theorem
`VoltaProofs.NAME` whose type is exactly the statement and whose proof uses no axiom beyond
`standardAxioms`. -/
def verdict (env : Environment) (statement : Name) : StateM AxiomCache String := do
  let short := statement.replacePrefix `VoltaChallenge .anonymous
  let theorem_ := `VoltaProofs ++ short

  -- The theorem must exist, state exactly the statement, and have a proof.
  let some ci := env.find? theorem_
    | return s!"missing {short}"
  if ci.type != .const statement [] then
    return s!"mistyped {short}"
  if (ci.value? (allowOpaque := true)).isNone then
    return s!"unproved {short}"

  -- Its proof may use only the standard axioms (`sorry` is the axiom `sorryAx`).
  let extra := (← axiomsOf env theorem_).filter (!standardAxioms.contains ·)
  if extra.isEmpty then
    return s!"proved {short}"

  return s!"axioms {short} {" ".intercalate (extra.map toString)}"

/-! ## Entry point -/

/-- The statements to prove: the definitions of `challenge` in namespace `VoltaChallenge`,
sorted by name. -/
def challengeStatements (env : Environment) : IO (Array Name) := do
  let some challenge := env.getModuleIdx? `challenge
    | throw <| IO.userError "proof does not import challenge"
  let names := env.header.moduleData[challenge.toNat]!.constNames.filter fun n =>
    (`VoltaChallenge).isPrefixOf n && (env.find? n).any (·.isDefinition)
  return names.qsort Name.lt

def main : IO Unit := do
  -- Load `proof` and, through its imports, `challenge` and Mathlib.
  initSearchPath (← findSysroot)
  let env ← importModules #[{ module := `proof }] {}

  -- One verdict per statement, all sharing one axiom cache.
  let statements ← challengeStatements env
  let lines := Id.run <| (statements.mapM (verdict env)).run' {}
  for line in lines do
    IO.println line
