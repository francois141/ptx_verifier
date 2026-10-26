# volta_viz

The event-graph viewer. It records kernel runs into a directory (a **run
store**) and turns that store into **one self-contained HTML page** showing
each run's event graph as a space-time diagram. The diagram has a lane per
thread, per issuing thread's async ops and per sync object; the typed edges;
the graph checks' findings; and the PTX source behind every event.

```sh
just viz   # VOLTA_VIZ_DIR=<dir> cargo test -p volta_pipeline, then volta viz <dir> -o target/volta-viz/volta-graphs.html
```

## High-level logic

```
Run { outcome: Executed { graph, arena, report } | NotStarted { cause, error }, source, ... }
   │ write_run(dir, &run)           (store.rs, export.rs)
   ▼
<dir>/<suite>/<test>[~n].json       the run as a `volta-viz 1` document
<dir>/<suite>/<test>[~n].meta.json  its summary (status, counts)
   │ write_page(dir, out)           (page.rs)
   ▼
one HTML page: viewer/{page.html, style.css, app.js} inlined
               + every document as an inert <script type="application/json"> block
```

- `store.rs`: the store layout. The page's index is built from the
  `.meta.json` summaries alone, so no document is parsed up front.
- `export.rs`: one run to its JSON document, and its **status**: race-free,
  race-condition (a memory-conflict, proxy-order or tensor-order failure),
  check-failed, deadlock, unsupported, unknown, error or unchecked.
- `json.rs`: a minimal JSON value and compact writer (the crate's only wire
  format; no serde).
- `page.rs`: assembles the page. A run's JSON is parsed only when it is opened,
  so the page loads quickly however many runs it holds.

## How the visual graph is built

### In Rust (`export.rs`)

1. **Lanes** (`Lanes::of`): each thread gets a lane, followed by an async lane
   if it issues async ops. Then each sync object gets a lane. Every event goes
   in the lane of its `ExecContext`: `Thread(t)` to t's lane, `Async(op)` to
   the issuer's async lane, `Generation(g)` to g's object's lane.
2. **Events** are compact rows `[lane, pc or -1, category, label, detail
   pairs...]`. Strings and `key=value` detail pairs are interned into
   document-wide tables, because a large trace holds tens of thousands of
   near-identical events.
3. **Edges** (`edges`): flat `[from, to, ...]` lists per kind:
   - `contribute` (contribution -> generation completion) and `release`
     (completion -> `Resume`). An `ExecutionOnly` collective's member edges
     get `-execution-only` kinds and are drawn dashed, because they order
     nothing;
   - `pipeline`: `volta_graph_check::pipeline`'s `E_pipeline` edges.

   Program order is implicit in each lane's event sequence. Each async op is
   listed once as `[issue, completion or -1, effects...]` instead of two edges
   per effect.
4. **Findings**: every check's witnesses and unresolved obligations, and a
   stuck trace's blocked threads, resolved to event ids so the page can ring
   them.
5. **Source**: the PTX text and a pc -> line map from the graph's
   `Provenance`.

### In the browser (`viewer/app.js`)

`derive(doc)` lays out rows by **longest-path layering**. An event sits one row
below its lane predecessor and below the source of every edge into it. Edges
run forward in trace order, so one pass in event order is enough. Around the
diagram the page has an overview of all runs (statuses, suites), a step ruler,
a minimap while zoomed, a legend that highlights or steps through one event
kind, and keyboard navigation (`?` lists the keys).

## Dependencies

`volta_graph` (the graph), `volta_graph_check` (findings, pipeline edges) and
`volta_expr` (rendering stored values). `tests/viewer_tests.rs` covers export
and page assembly.
