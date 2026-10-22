"use strict";
// The viewer over the runs embedded in this page: `#volta-index` lists every run's summary and
// `#run-<i>` holds the i-th run's document, parsed only when the run is opened.
(function () {
  const HEADER_H = 64;
  const BAND_H = 20;
  const GUTTER_W = 44;
  const MAX_LISTED = 100;
  const FINDINGS_SHOWN = 6;
  // Edge kinds with more edges than this start hidden: in an overview they only paint a wall.
  const DENSE_EDGES = 4000;
  // Up to this many edges of one kind on screen stay opaque; more fade, so a fan reads as a shape.
  const CLEAR_EDGES = 60;
  const MINI_W = 184;
  const MINI_H = 120;

  // A run's outcome, as `Status` in export.rs names it.
  const STATUSES = [
    ["race-free", "Race-free"],
    ["race-condition", "Race condition"],
    ["check-failed", "Check failed"],
    ["deadlock", "Deadlock"],
    ["unsupported", "Unsupported"],
    ["unknown", "Unknown"],
    ["error", "Error"],
    ["unchecked", "Not checked"],
  ];
  const STATUS_NAME = Object.fromEntries(STATUSES);
  // The outcomes that reject the kernel itself.
  const FAILING = ["race-condition", "check-failed", "deadlock"];

  const CATEGORIES = {
    read: { shape: "circle", color: "--c-read", name: "Read" },
    write: { shape: "circle", color: "--c-write", name: "Write" },
    sync: { shape: "tri-down", color: "--c-sync", name: "Arrive / contribute" },
    wait: { shape: "tri-down-open", color: "--c-sync", name: "Wait start" },
    resume: { shape: "tri-up", color: "--c-resume", name: "Resume" },
    generation: { shape: "diamond", color: "--c-gen", name: "Generation complete" },
    issue: { shape: "square", color: "--c-async", name: "Async issue" },
    "async-complete": { shape: "square-open", color: "--c-async", name: "Async complete" },
    commit: { shape: "bar", color: "--c-misc", name: "Commit group" },
    fence: { shape: "bar", color: "--c-fence", name: "Fence" },
    lifetime: { shape: "ring", color: "--c-misc", name: "Init / inval" },
    tmem: { shape: "square", color: "--c-tmem", name: "TMEM alloc / dealloc" },
    exit: { shape: "cross", color: "--c-exit", name: "Exit" },
  };
  const OPEN_SHAPES = new Set(["tri-down-open", "square-open", "ring", "cross"]);

  const EDGES = {
    contribute: { color: "--e-contribute", dash: [], name: "Contribute" },
    release: { color: "--e-release", dash: [], name: "Release" },
    "contribute-execution-only": { color: "--e-contribute", dash: [4, 4], name: "Contribute (execution only)" },
    "release-execution-only": { color: "--e-release", dash: [4, 4], name: "Release (execution only)" },
    spawn: { color: "--e-async", dash: [5, 3], name: "Spawn" },
    complete: { color: "--e-async", dash: [], name: "Complete" },
    pipeline: { color: "--e-pipeline", dash: [2, 3], name: "Pipeline" },
  };

  // Paths in a 24-unit box, stroked; a leading "!" fills the path instead.
  const ICONS = {
    up: ["M6 15l6-6 6 6"],
    down: ["M6 9l6 6 6-6"],
    left: ["M15 6l-6 6 6 6"],
    right: ["M9 6l6 6-6 6"],
    plus: ["M12 5v14M5 12h14"],
    minus: ["M5 12h14"],
    fit: ["M4 9V4h5M20 9V4h-5M4 15v5h5M20 15v5h-5"],
    close: ["M6 6l12 12M18 6L6 18"],
    map: ["M9 4L3 6v14l6-2 6 2 6-2V4l-6 2-6-2z", "M9 4v14M15 6v14"],
    search: ["M11 4a7 7 0 1 0 0 14a7 7 0 1 0 0-14z", "M20 20l-4-4"],
    sun: [
      "M12 8a4 4 0 1 0 0 8a4 4 0 1 0 0-8z",
      "M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4",
    ],
    moon: ["M20 14.5A8.5 8.5 0 1 1 9.5 4a6.5 6.5 0 0 0 10.5 10.5z"],
    auto: ["M12 3a9 9 0 1 0 0 18a9 9 0 1 0 0-18z", "!M12 3a9 9 0 0 0 0 18z"],
    check: ["M5 12.5l4.5 4.5L19 7.5"],
    cross: ["M7 7l10 10M17 7L7 17"],
    question: ["M9.5 9a2.5 2.5 0 1 1 3.5 2.3c-.6.3-1 .9-1 1.6V14", "M12 17.5v.01"],
    alert: ["M12 3.5l9 16h-18z", "M12 10v4.5M12 17.2v.01"],
    target: ["M12 4a8 8 0 1 0 0 16a8 8 0 1 0 0-16z", "M12 9a3 3 0 1 0 0 6a3 3 0 1 0 0-6z"],
  };

  const SHORTCUTS = [
    ["Navigation"],
    [["/"], "Filter the tests"],
    [["[", "]"], "Previous / next run in the list"],
    [["↑", "↓"], "Previous / next event in the lane"],
    [["←", "→"], "Nearest event in the neighboring lane"],
    [["n", "⇧ n"], "Next / previous event of the focused set"],
    [["Esc"], "Clear the selection and the focus"],
    ["View"],
    [["f"], "Fit the graph"],
    [["+", "−"], "Zoom in / out"],
    [["m"], "Show or hide the overview map"],
    [["?"], "Show this help"],
    ["Mouse"],
    [["drag"], "Pan (also on the overview map)"],
    [["wheel"], "Scroll, sideways with ⇧"],
    [["⌘ / ctrl", "wheel"], "Zoom"],
    [["alt", "wheel"], "Stretch or squeeze the rows"],
    [["double-click"], "Zoom in at the pointer"],
  ];

  const byId = (id) => document.getElementById(id);
  const fmt = (n) => Number(n).toLocaleString("en-US");
  const clamp = (x, lo, hi) => Math.min(hi, Math.max(lo, x));

  function h(tag, props, ...kids) {
    const node = document.createElement(tag);
    for (const [k, v] of Object.entries(props || {})) {
      if (v == null || v === false) continue;
      if (k === "class") node.className = v;
      else if (k === "text") node.textContent = v;
      else if (k.startsWith("on")) node.addEventListener(k.slice(2), v);
      else node.setAttribute(k, v === true ? "" : String(v));
    }
    for (const kid of kids.flat(Infinity)) {
      if (kid == null || kid === false) continue;
      node.append(kid instanceof Node ? kid : String(kid));
    }
    return node;
  }

  // `replaceChildren` that skips the `null`s and `false`s of optional parts.
  function fill(node, ...kids) {
    node.replaceChildren(...kids.flat(Infinity).filter((k) => k != null && k !== false));
  }

  function icon(name) {
    const NS = "http://www.w3.org/2000/svg";
    const svg = document.createElementNS(NS, "svg");
    svg.setAttribute("viewBox", "0 0 24 24");
    svg.setAttribute("class", "icon");
    svg.setAttribute("aria-hidden", "true");
    for (const d of ICONS[name]) {
      const path = document.createElementNS(NS, "path");
      if (d.startsWith("!")) path.setAttribute("class", "solid");
      path.setAttribute("d", d.replace(/^!/, ""));
      svg.append(path);
    }
    return svg;
  }

  // Test names are long snake_case identifiers: let them wrap after each underscore.
  function breakable(text) {
    const parts = text.split("_");
    return parts.map((p, i) => (i < parts.length - 1 ? [p + "_", h("wbr")] : p));
  }

  function storageGet(key) {
    try {
      return window.localStorage.getItem(key);
    } catch (_) {
      return null;
    }
  }

  function storageSet(key, value) {
    try {
      if (value == null) window.localStorage.removeItem(key);
      else window.localStorage.setItem(key, value);
    } catch (_) {
      /* storage unavailable: the preference lasts for this visit only */
    }
  }

  let INDEX = [];
  try {
    INDEX = JSON.parse(byId("volta-index").textContent);
  } catch (_) {
    INDEX = [];
  }
  const KEY_TO_INDEX = new Map(INDEX.map((m, i) => [m.key, i]));
  const RUNS_OF_TEST = new Map();
  INDEX.forEach((m, i) => {
    const id = m.suite + "/" + m.test;
    if (!RUNS_OF_TEST.has(id)) RUNS_OF_TEST.set(id, []);
    RUNS_OF_TEST.get(id).push(i);
  });
  const siblingRuns = (m) => RUNS_OF_TEST.get(m.suite + "/" + m.test) || [];

  const docCache = new Map();
  function loadDoc(i) {
    if (docCache.has(i)) {
      const doc = docCache.get(i);
      docCache.delete(i);
      docCache.set(i, doc);
      return doc;
    }
    const doc = decode(JSON.parse(byId("run-" + i).textContent));
    docCache.set(i, doc);
    if (docCache.size > 12) docCache.delete(docCache.keys().next().value);
    return doc;
  }

  // Expands a document's compact form: event rows of interned strings and detail pairs, edges
  // as flat per-kind lists, and async ops as `[issue, completion, effects...]`.
  function decode(raw) {
    if (!raw.events) return raw;
    const S = raw.strings;
    const P = raw.pairs;
    const events = raw.events.map((row) => ({
      lane: row[0],
      pc: row[1] < 0 ? null : row[1],
      cat: S[row[2]],
      label: S[row[3]],
      pairs: row.slice(4),
    }));
    const edges = [];
    for (const [kind, flat] of Object.entries(raw.edges)) {
      for (let i = 0; i + 1 < flat.length; i += 2) edges.push([flat[i], flat[i + 1], kind]);
    }
    for (const [issue, completion, ...effects] of raw.asyncOps) {
      for (const e of effects) {
        edges.push([issue, e, "spawn"]);
        if (completion >= 0) edges.push([e, completion, "complete"]);
      }
      if (!effects.length && completion >= 0) edges.push([issue, completion, "spawn"]);
    }
    const info = (ev) => ev.pairs.map((p) => [S[P[2 * p]], S[P[2 * p + 1]]]);
    return Object.assign({}, raw, { events, edges, info });
  }

  // ---------------------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------------------

  const ui = {
    filter: "",
    statuses: new Set(STATUSES.map(([s]) => s)),
    collapsed: new Set(),
    visibleOrder: [],
    legendOpen: { open: true, closed: false }[storageGet("volta-viz-legend")] ?? (window.innerWidth > 1100 && window.innerHeight >= 760),
    minimap: storageGet("volta-viz-minimap") !== "off",
  };

  const state = {
    runIndex: -1,
    doc: null,
    g: null,
    cols: [],
    colOf: null,
    cells: new Map(),
    edgeOn: {},
    showAsync: true,
    showObjects: true,
    threadFilter: null,
    selected: -1,
    hover: -1,
    highlightCat: null,
    focus: null,
    view: { sx: 30, sy: 20, tx: 0, ty: 0 },
    tab: "checks",
    mini: null,
  };

  let colors = {};
  let fonts = { sans: "sans-serif", mono: "monospace" };
  function readColors() {
    const cs = getComputedStyle(document.documentElement);
    const names = new Set([
      "--canvas",
      "--header-bg",
      "--border",
      "--text",
      "--muted",
      "--accent",
      "--accent-soft",
      "--on-accent",
      "--bad",
      "--warn",
      "--e-po",
      "--lane-guide",
      "--lane-sep",
      "--lane-fill",
      "--row-guide",
      "--hover",
    ]);
    for (const c of Object.values(CATEGORIES)) names.add(c.color);
    for (const e of Object.values(EDGES)) names.add(e.color);
    colors = {};
    for (const n of names) colors[n] = cs.getPropertyValue(n).trim() || "#888";
    fonts = {
      sans: getComputedStyle(document.body).fontFamily,
      mono: cs.getPropertyValue("--mono").trim() || "monospace",
    };
    state.mini = null;
  }

  // ---------------------------------------------------------------------------------------
  // Graph model derived from a document
  // ---------------------------------------------------------------------------------------

  // Rows by longest-path layering: an event sits below its lane predecessor and below the
  // source of every typed edge into it. Edges run forward in trace order, so one pass in
  // event order suffices.
  function derive(doc) {
    const n = doc.events.length;
    const incoming = Array.from({ length: n }, () => []);
    const outgoing = Array.from({ length: n }, () => []);
    const edgesByKind = {};
    doc.edges.forEach(([from, to, kind], i) => {
      outgoing[from].push(i);
      incoming[to].push(i);
      (edgesByKind[kind] = edgesByKind[kind] || []).push(i);
    });
    const row = new Int32Array(n);
    const prevInLane = new Int32Array(n).fill(-1);
    const nextInLane = new Int32Array(n).fill(-1);
    const laneRow = new Int32Array(doc.lanes.length).fill(-1);
    const laneLast = new Int32Array(doc.lanes.length).fill(-1);
    let rows = 0;
    for (let e = 0; e < n; e++) {
      const lane = doc.events[e].lane;
      let r = laneRow[lane] + 1;
      for (const i of incoming[e]) {
        const from = doc.edges[i][0];
        if (from < e) r = Math.max(r, row[from] + 1);
      }
      row[e] = r;
      laneRow[lane] = r;
      if (laneLast[lane] >= 0) {
        prevInLane[e] = laneLast[lane];
        nextInLane[laneLast[lane]] = e;
      }
      laneLast[lane] = e;
      rows = Math.max(rows, r + 1);
    }
    const byCategory = {};
    doc.events.forEach((ev, e) => (byCategory[ev.cat] = byCategory[ev.cat] || []).push(e));

    const findingsOf = new Map();
    const severity = new Map();
    const note = (e, entry) => {
      if (!findingsOf.has(e)) findingsOf.set(e, []);
      findingsOf.get(e).push(entry);
      const rank = { fail: 3, stuck: 2, unknown: 1 };
      if (!severity.has(e) || rank[entry.severity] > rank[severity.get(e)]) {
        severity.set(e, entry.severity);
      }
    };
    for (const check of doc.checks || []) {
      if (check.verdict === "pass") continue;
      const sev = check.verdict === "fail" ? "fail" : "unknown";
      for (const f of check.findings) {
        for (const e of f.events) note(e, { severity: sev, title: check.name, text: f.text });
      }
    }
    for (const f of (doc.terminal && doc.terminal.notes) || []) {
      for (const e of f.events) {
        note(e, { severity: "stuck", title: "trace " + doc.terminal.kind, text: f.text });
      }
    }

    const lineEvents = new Map();
    doc.events.forEach((ev, e) => {
      const ins = ev.pc != null ? doc.instructions[ev.pc] : null;
      if (!ins || ins.line == null) return;
      if (!lineEvents.has(ins.line)) lineEvents.set(ins.line, []);
      lineEvents.get(ins.line).push(e);
    });
    return {
      row,
      rows,
      incoming,
      outgoing,
      edgesByKind,
      prevInLane,
      nextInLane,
      byCategory,
      findingsOf,
      severity,
      lineEvents,
    };
  }

  function laneVisible(lane) {
    if (lane.kind === "object") return state.showObjects;
    if (lane.kind === "async" && !state.showAsync) return false;
    return !state.threadFilter || state.threadFilter.has(lane.thread);
  }

  function applyLanes() {
    const doc = state.doc;
    state.cols = [];
    state.colOf = new Int32Array(doc.lanes.length).fill(-1);
    doc.lanes.forEach((lane, i) => {
      if (!laneVisible(lane)) return;
      state.colOf[i] = state.cols.length;
      state.cols.push(i);
    });
    state.cells = new Map();
    const rows = state.g.rows;
    doc.events.forEach((ev, e) => {
      const col = state.colOf[ev.lane];
      if (col >= 0) state.cells.set(col * rows + state.g.row[e], e);
    });
    state.mini = null;
  }

  function parseThreadFilter(text) {
    const trimmed = text.trim();
    if (!trimmed) return { set: null, ok: true };
    const set = new Set();
    let ok = true;
    for (const part of trimmed.split(/[\s,]+/)) {
      if (!part) continue;
      const m = /^t?(\d+)(?:-t?(\d+))?$/.exec(part);
      if (!m) {
        ok = false;
        continue;
      }
      const lo = Number(m[1]);
      const hi = m[2] != null ? Number(m[2]) : lo;
      for (let t = Math.min(lo, hi); t <= Math.max(lo, hi) && t - lo < 100000; t++) set.add(t);
    }
    return { set, ok };
  }

  // ---------------------------------------------------------------------------------------
  // Sidebar
  // ---------------------------------------------------------------------------------------

  const suiteName = (suite) => suite.replace(/_tests$/, "").replace(/_/g, " ");

  function matchesFilter(m) {
    if (!ui.statuses.has(m.status)) return false;
    if (!ui.filter) return true;
    const hay = [m.test, m.ptx || "", m.kernel || "", m.suite].join(" ").toLowerCase();
    return ui.filter
      .toLowerCase()
      .split(/\s+/)
      .every((word) => hay.includes(word));
  }

  function statusCounts(indices) {
    const counts = {};
    for (const i of indices) counts[INDEX[i].status] = (counts[INDEX[i].status] || 0) + 1;
    return counts;
  }

  // Segments proportional to each status's count; `status-bar` greys out filtered statuses.
  function statusBar(counts, cls) {
    return h(
      "div",
      { class: cls, "aria-hidden": "true" },
      STATUSES.filter(([s]) => counts[s]).map(([s, name]) => {
        const off = cls === "status-bar" && !ui.statuses.has(s);
        const seg = h("span", { class: s + (off ? " off" : ""), title: name + ": " + fmt(counts[s]) });
        seg.style.flex = counts[s] + " 1 0";
        return seg;
      }),
    );
  }

  function setStatuses(statuses) {
    ui.statuses = statuses;
    renderStatusFilter();
    renderList();
  }

  function renderStatusFilter() {
    const counts = statusCounts(INDEX.keys());
    const all = STATUSES.map(([s]) => s);
    fill(byId("status-filter"),
      statusBar(counts, "status-bar"),
      h(
        "div",
        { class: "status-chips" },
        STATUSES.filter(([s]) => counts[s]).map(([s, name]) => {
          const on = ui.statuses.has(s);
          return h(
            "button",
            {
              class: "status-chip" + (on ? " on" : ""),
              type: "button",
              "aria-pressed": String(on),
              title: (on ? "Hide " : "Show ") + name.toLowerCase() + " runs (shift-click: only these)",
              onclick: (ev) => {
                const next = new Set(ui.statuses);
                if (ev.shiftKey) {
                  const solo = next.size === 1 && next.has(s);
                  setStatuses(new Set(solo ? all : [s]));
                  return;
                }
                if (on) next.delete(s);
                else next.add(s);
                setStatuses(next);
              },
            },
            h("span", { class: "dot " + s }),
            name,
            h("span", { class: "count", text: fmt(counts[s]) }),
          );
        }),
      ),
    );
  }

  function renderList() {
    const list = byId("test-list");
    const groups = new Map();
    INDEX.forEach((m, i) => {
      if (!matchesFilter(m)) return;
      if (!groups.has(m.suite)) groups.set(m.suite, []);
      groups.get(m.suite).push(i);
    });
    ui.visibleOrder = [];
    const nodes = [];
    for (const [suite, items] of groups) {
      const collapsed = ui.collapsed.has(suite) && !ui.filter;
      nodes.push(
        h(
          "button",
          {
            class: "suite-head",
            type: "button",
            "aria-expanded": String(!collapsed),
            "data-suite": suite,
            onclick: () => {
              if (ui.collapsed.has(suite)) ui.collapsed.delete(suite);
              else ui.collapsed.add(suite);
              renderList();
            },
          },
          h("span", { class: "chev", "aria-hidden": "true" }),
          h("span", { class: "suite-name", text: suiteName(suite) }),
          statusBar(statusCounts(items), "mini-bar"),
          h("span", { class: "count", text: fmt(items.length) }),
        ),
      );
      if (collapsed) continue;
      const ul = h("ul", { class: "suite-items" });
      for (const i of items) {
        const m = INDEX[i];
        ui.visibleOrder.push(i);
        const runs = siblingRuns(m).length;
        ul.append(
          h(
            "li",
            null,
            h(
              "a",
              {
                href: "#" + m.key,
                class: "test-item" + (i === state.runIndex ? " active" : ""),
                "data-index": i,
                title: m.test + (m.ptx ? "\n" + m.ptx : "") + "\n" + STATUS_NAME[m.status],
              },
              h("span", { class: "dot " + m.status, "aria-label": STATUS_NAME[m.status] }),
              h("span", { class: "test-name" }, breakable(m.test.replace(/^test_/, ""))),
              runs > 1 ? h("span", { class: "run-badge", text: "#" + m.run }) : null,
            ),
          ),
        );
      }
      nodes.push(ul);
    }
    if (!nodes.length) {
      nodes.push(h("p", { class: "hint pad", text: "No run matches the filter." }));
    }
    fill(list, ...nodes);
    byId("sidebar-foot").textContent =
      fmt(ui.visibleOrder.length) + " of " + fmt(INDEX.length) + " runs";
  }

  function markActive() {
    for (const a of document.querySelectorAll(".test-item.active")) a.classList.remove("active");
    const a = document.querySelector('.test-item[data-index="' + state.runIndex + '"]');
    if (a) {
      a.classList.add("active");
      a.scrollIntoView({ block: "nearest" });
    }
  }

  function revealSuite(suite) {
    ui.collapsed.delete(suite);
    renderList();
    const head = document.querySelector('.suite-head[data-suite="' + CSS.escape(suite) + '"]');
    if (head) head.scrollIntoView({ block: "start", behavior: "smooth" });
  }

  function stepRun(d) {
    const order = ui.visibleOrder;
    if (!order.length) return;
    const at = order.indexOf(state.runIndex);
    const next = at < 0 ? order[0] : order[clamp(at + d, 0, order.length - 1)];
    location.hash = INDEX[next].key;
  }

  // ---------------------------------------------------------------------------------------
  // Opening a run
  // ---------------------------------------------------------------------------------------

  function openRun(i) {
    if (i < 0 || i >= INDEX.length) return;
    let doc;
    try {
      doc = loadDoc(i);
    } catch (err) {
      showMessage("This run's document could not be read: " + err.message);
      return;
    }
    state.runIndex = i;
    state.doc = doc;
    state.selected = -1;
    state.hover = -1;
    state.highlightCat = null;
    state.focus = null;
    state.g = doc.events ? derive(doc) : null;
    state.edgeOn = {};
    for (const kind of Object.keys(EDGES)) {
      state.edgeOn[kind] = !state.g || (state.g.edgesByKind[kind] || []).length <= DENSE_EDGES;
    }
    if (state.g) {
      applyLanes();
    }
    showTooltip(-1);
    document.title = INDEX[i].test + " · Volta Event Graphs";
    renderHeader();
    renderToolbar();
    renderLegend();
    renderFocusBar();
    renderViewControls();
    byId("main").classList.toggle("no-graph", !state.g);
    showEmptyState(null);
    showMessage(null);
    if (!state.g) {
      if (doc.error) renderNotStarted();
      else showMessage("This run recorded no graph.");
    } else if (!doc.events.length) {
      showMessage("The graph has no events.");
    }
    sourceBuiltFor = -1;
    setTab(state.tab === "event" ? "checks" : state.tab);
    updateBadges();
    markActive();
    resizeCanvas();
    fit();
  }

  function showMessage(text) {
    const box = byId("canvas-message");
    box.hidden = !text;
    box.textContent = text || "";
  }

  function showEmptyState(node) {
    const box = byId("empty-state");
    box.hidden = !node;
    if (node) {
      fill(box, node);
      box.scrollTop = 0;
    } else {
      fill(box);
    }
  }

  function renderHeader() {
    const m = INDEX[state.runIndex];
    const doc = state.doc;
    const runs = siblingRuns(m);
    const launch = doc.launch;
    const fact = (name, value, mono) =>
      value == null
        ? null
        : h(
            "span",
            { class: "fact" },
            h("span", { class: "k", text: name }),
            h("span", { class: "v" + (mono ? " mono" : ""), text: String(value) }),
          );
    fill(byId("run-header"),
      h(
        "div",
        { class: "crumbs" },
        h("button", {
          class: "suite",
          type: "button",
          text: suiteName(m.suite),
          title: "Show this suite in the list",
          onclick: () => revealSuite(m.suite),
        }),
        h("span", { class: "sep", text: "/" }),
        h("h1", null, breakable(m.test)),
        runs.length > 1
          ? h(
              "span",
              { class: "runs" },
              h("span", { class: "runs-label", text: "run" }),
              runs.map((j) =>
                h("a", {
                  href: "#" + INDEX[j].key,
                  class: "run-link" + (j === state.runIndex ? " active" : ""),
                  text: INDEX[j].run,
                  title: INDEX[j].kernel ? "kernel " + INDEX[j].kernel : null,
                }),
              ),
            )
          : null,
      ),
      h(
        "div",
        { class: "facts" },
        h(
          "span",
          { class: "pills" },
          h("span", { class: "pill status " + m.status, text: STATUS_NAME[m.status] }),
          m.terminal ? h("span", { class: "pill terminal " + m.terminal, text: "trace " + m.terminal }) : null,
        ),
        fact("kernel", m.kernel, true),
        launch ? fact("block", launch.block.join("×")) : null,
        launch && launch.grid.some((d) => d !== 1) ? fact("grid", launch.grid.join("×")) : null,
        m.events != null ? fact("events", fmt(m.events)) : null,
        fact("ptx", m.ptx || "built by the test", !!m.ptx),
      ),
    );
  }

  // ---------------------------------------------------------------------------------------
  // Toolbar, legend, view controls and focus bar
  // ---------------------------------------------------------------------------------------

  function toggleChip({ label, count, on, onchange, lead, title }) {
    const button = h(
      "button",
      { class: "toggle-chip" + (on ? " on" : ""), type: "button", "aria-pressed": String(on), title },
      lead || h("span", { class: "check-mark", "aria-hidden": "true" }),
      h("span", { text: label }),
      count != null ? h("span", { class: "count", text: fmt(count) }) : null,
    );
    button.addEventListener("click", () => {
      const next = button.getAttribute("aria-pressed") !== "true";
      button.setAttribute("aria-pressed", String(next));
      button.classList.toggle("on", next);
      onchange(next);
    });
    return button;
  }

  function renderToolbar() {
    const g = state.g;
    const bar = byId("toolbar");
    if (!g) {
      fill(bar);
      return;
    }
    const doc = state.doc;
    const hasAsync = doc.lanes.some((l) => l.kind === "async");
    const hasObjects = doc.lanes.some((l) => l.kind === "object");
    const threadInput = h("input", {
      id: "thread-filter",
      type: "text",
      placeholder: "All threads (e.g. 0-3, 32)",
      spellcheck: "false",
      autocomplete: "off",
      "aria-label": "Threads to show",
    });
    let timer = 0;
    threadInput.addEventListener("input", () => {
      clearTimeout(timer);
      timer = setTimeout(() => {
        const { set, ok } = parseThreadFilter(threadInput.value);
        threadInput.classList.toggle("invalid", !ok);
        state.threadFilter = set;
        applyLanes();
        fit();
      }, 150);
    });
    if (state.threadFilter) {
      threadInput.value = [...state.threadFilter].join(",");
    }
    const edgeToggles = Object.entries(EDGES)
      .filter(([kind]) => g.edgesByKind[kind])
      .map(([kind, spec]) =>
        toggleChip({
          label: spec.name,
          count: g.edgesByKind[kind].length,
          on: state.edgeOn[kind],
          lead: h("span", { class: "edge-swatch " + kind, "aria-hidden": "true" }),
          title:
            g.edgesByKind[kind].length > DENSE_EDGES
              ? "Hidden at first: " + fmt(g.edgesByKind[kind].length) + " edges"
              : null,
          onchange: (on) => {
            state.edgeOn[kind] = on;
            draw();
          },
        }),
      );
    const goto = h("input", {
      type: "text",
      class: "goto",
      placeholder: "Go to e#",
      spellcheck: "false",
      "aria-label": "Go to event",
      onkeydown: (e) => {
        if (e.key !== "Enter") return;
        const n = parseInt(e.target.value.trim().replace(/^e/i, ""), 10);
        if (Number.isInteger(n) && n >= 0 && n < doc.events.length) {
          select(n, { center: true });
          e.target.classList.remove("invalid");
        } else {
          e.target.classList.add("invalid");
        }
      },
      oninput: (e) => e.target.classList.remove("invalid"),
    });
    const findingThreads = new Set();
    for (const e of g.severity.keys()) {
      const lane = doc.lanes[doc.events[e].lane];
      if (lane.thread != null) findingThreads.add(lane.thread);
    }
    fill(bar,
      h(
        "div",
        { class: "group" },
        h("span", { class: "group-label", text: "Lanes" }),
        threadInput,
        findingThreads.size
          ? h(
              "button",
              {
                class: "btn",
                type: "button",
                title: "Show only the threads the findings involve",
                onclick: () => {
                  threadInput.value = [...findingThreads].sort((x, y) => x - y).join(",");
                  threadInput.dispatchEvent(new Event("input"));
                },
              },
              icon("target"),
              "Finding threads",
            )
          : null,
        hasAsync
          ? toggleChip({
              label: "Async",
              on: state.showAsync,
              title: "Lanes of each thread's async operations",
              onchange: (on) => {
                state.showAsync = on;
                applyLanes();
                fit();
              },
            })
          : null,
        hasObjects
          ? toggleChip({
              label: "Sync objects",
              on: state.showObjects,
              title: "Lanes of barriers, mbarriers and warp collectives",
              onchange: (on) => {
                state.showObjects = on;
                applyLanes();
                fit();
              },
            })
          : null,
      ),
      edgeToggles.length
        ? h("div", { class: "group" }, h("span", { class: "group-label", text: "Edges" }), edgeToggles)
        : null,
      h("div", { class: "group right" }, h("span", { class: "goto-wrap" }, icon("search"), goto)),
    );
  }

  function swatch(cat, size) {
    const canvas = h("canvas", { class: "swatch", width: size * 2, height: size * 2, "aria-hidden": "true" });
    canvas.style.width = canvas.style.height = size + "px";
    const ctx = canvas.getContext("2d");
    ctx.scale(2, 2);
    const spec = CATEGORIES[cat] || CATEGORIES.exit;
    ctx.beginPath();
    shapePath(ctx, spec.shape, size / 2, size / 2, size * 0.33);
    paintShape(ctx, spec.shape, colors[spec.color], size * 0.33);
    return canvas;
  }

  function catDot(cat) {
    const spec = CATEGORIES[cat] || CATEGORIES.exit;
    return h("span", {
      class: "cat-dot" + (OPEN_SHAPES.has(spec.shape) ? " open" : ""),
      style: "--dot: var(" + spec.color + ")",
      "aria-hidden": "true",
    });
  }

  // The non-event marks; with a graph, only the rings it actually draws.
  function markItems(g) {
    const severities = g ? new Set(g.severity.values()) : null;
    return [
      h("span", { class: "legend-item" }, h("span", { class: "edge-swatch po" }), h("span", { class: "name", text: "Program order" })),
      severities && !severities.has("fail")
        ? null
        : h("span", { class: "legend-item" }, h("span", { class: "ring-swatch" }), h("span", { class: "name", text: "Finding (failed check)" })),
      severities && !severities.has("unknown") && !severities.has("stuck")
        ? null
        : h("span", { class: "legend-item" }, h("span", { class: "ring-swatch unknown" }), h("span", { class: "name", text: "Unresolved or blocked" })),
      h("span", { class: "legend-item" }, h("span", { class: "ring-swatch focus" }), h("span", { class: "name", text: "Focused" })),
    ];
  }

  function renderLegend() {
    const g = state.g;
    const legend = byId("legend");
    if (!g || !state.doc.events.length) {
      legend.hidden = true;
      fill(legend);
      return;
    }
    legend.hidden = false;
    legend.classList.toggle("collapsed", !ui.legendOpen);
    const items = Object.keys(CATEGORIES)
      .filter((cat) => g.byCategory[cat])
      .map((cat) =>
        h(
          "button",
          {
            class: "legend-item",
            type: "button",
            title: "Step through every " + CATEGORIES[cat].name.toLowerCase() + " event",
            onmouseenter: () => {
              state.highlightCat = cat;
              draw();
            },
            onmouseleave: () => {
              state.highlightCat = null;
              draw();
            },
            onclick: () => focusEvents(g.byCategory[cat], CATEGORIES[cat].name + " events"),
          },
          swatch(cat, 12),
          h("span", { class: "name", text: CATEGORIES[cat].name }),
          h("span", { class: "count", text: fmt(g.byCategory[cat].length) }),
        ),
      );
    fill(legend,
      h(
        "button",
        {
          class: "legend-head",
          type: "button",
          "aria-expanded": String(ui.legendOpen),
          title: "Hover a kind to highlight it; click it to step through its events",
          onclick: () => {
            ui.legendOpen = !ui.legendOpen;
            storageSet("volta-viz-legend", ui.legendOpen ? "open" : "closed");
            renderLegend();
          },
        },
        h("span", { class: "chev", "aria-hidden": "true" }),
        "Legend",
      ),
      h(
        "div",
        { class: "legend-body" },
        h("div", { class: "legend-grid" + (items.length > 6 ? " wide" : "") }, items),
        h("div", { class: "legend-sep" }),
        h("div", { class: "legend-grid" + (items.length > 6 ? " wide" : "") }, markItems(g)),
      ),
    );
  }

  function toggleMinimap() {
    ui.minimap = !ui.minimap;
    storageSet("volta-viz-minimap", ui.minimap ? null : "off");
    renderViewControls();
    draw();
  }

  function renderViewControls() {
    const box = byId("view-controls");
    const on = !!(state.g && state.doc.events.length);
    box.hidden = !on;
    if (!on) {
      fill(box);
      return;
    }
    fill(box,
      h(
        "button",
        {
          class: "btn icon ghost" + (ui.minimap ? " on" : ""),
          type: "button",
          title: "Overview map while zoomed in (m)",
          "aria-pressed": String(ui.minimap),
          onclick: toggleMinimap,
        },
        icon("map"),
      ),
      h("span", { class: "divider", "aria-hidden": "true" }),
      h("button", { class: "btn icon ghost", type: "button", title: "Zoom out (−)", onclick: () => zoomBy(1 / 1.4) }, icon("minus")),
      h("button", { class: "btn icon ghost", type: "button", title: "Zoom in (+)", onclick: () => zoomBy(1.4) }, icon("plus")),
      h("button", { class: "btn ghost", type: "button", title: "Fit the graph (f)", onclick: fit }, icon("fit"), "Fit"),
    );
  }

  function focusEvents(events, label) {
    if (!events.length || !state.g) return;
    state.focus = { events, label, cursor: 0 };
    renderFocusBar();
    select(events[0], { center: true, tab: false });
  }

  function clearFocus() {
    state.focus = null;
    renderFocusBar();
    draw();
  }

  function stepFocus(d) {
    const f = state.focus;
    if (!f) return;
    f.cursor = (f.cursor + d + f.events.length) % f.events.length;
    renderFocusBar();
    select(f.events[f.cursor], { center: true, tab: false });
  }

  function renderFocusBar() {
    const bar = byId("focus-bar");
    const f = state.focus;
    bar.hidden = !f;
    if (!f) return;
    fill(bar,
      h("span", { class: "focus-tag", text: "Focus" }),
      h("span", { class: "focus-label", text: f.label, title: f.label }),
      f.events.length > 1
        ? h(
            "span",
            { class: "focus-nav" },
            h("button", { class: "btn icon", type: "button", title: "Previous event (shift+n)", onclick: () => stepFocus(-1) }, icon("left")),
            h("span", { class: "pos", text: fmt(f.cursor + 1) + " / " + fmt(f.events.length) }),
            h("button", { class: "btn icon", type: "button", title: "Next event (n)", onclick: () => stepFocus(1) }, icon("right")),
          )
        : null,
      h("button", { class: "btn icon ghost", type: "button", title: "Clear the focus (Esc)", onclick: clearFocus }, icon("close")),
    );
  }

  // ---------------------------------------------------------------------------------------
  // Inspector
  // ---------------------------------------------------------------------------------------

  function setTab(tab) {
    state.tab = tab;
    for (const b of document.querySelectorAll(".tab")) {
      const on = b.dataset.tab === tab;
      b.classList.toggle("active", on);
      b.setAttribute("aria-selected", String(on));
    }
    for (const body of document.querySelectorAll(".tab-body")) body.hidden = body.id !== "tab-" + tab;
    renderTab();
  }

  function renderTab() {
    if (!state.doc) return;
    if (state.tab === "checks") renderChecks();
    else if (state.tab === "event") renderEvent();
    else if (state.tab === "source") renderSource();
  }

  function setBadge(id, text, cls, title) {
    const badge = byId(id);
    badge.textContent = text || "";
    badge.className = "tab-badge" + (cls ? " " + cls : "");
    if (title) badge.title = title;
    else badge.removeAttribute("title");
  }

  // The checks badge follows the run's outcome, which a deadlock or an aborted trace decides
  // even when every check passes.
  function updateBadges() {
    const doc = state.doc;
    const checks = (doc && doc.checks) || [];
    const failed = checks.filter((c) => c.verdict === "fail").length;
    const status = doc ? INDEX[state.runIndex].status : null;
    const name = status ? STATUS_NAME[status].toLowerCase() : "";
    if (FAILING.includes(status)) setBadge("badge-checks", failed || "!", "bad", failed ? failed + " failed" : name);
    else if (status === "error") setBadge("badge-checks", "!", "bad", doc.error ? "error: the execution never started" : name);
    else if (status === "unsupported") setBadge("badge-checks", "!", "warn", name);
    else if (status === "unknown") setBadge("badge-checks", "?", "warn", name);
    else if (status === "race-free") setBadge("badge-checks", "✓", "ok", name);
    else setBadge("badge-checks", "");
    setBadge("badge-event", state.selected >= 0 ? "e" + state.selected : "", "mono");
  }

  const section = (title, ...body) => h("section", { class: "panel-section" }, h("h2", null, title), body);
  const titled = (title, n) => [title, h("span", { class: "count", text: fmt(n) })];

  function eventChip(e) {
    const ev = state.doc.events && state.doc.events[e];
    return h(
      "button",
      {
        class: "chip event-chip",
        type: "button",
        title: ev ? ev.label : null,
        onclick: () => select(e, { center: true }),
      },
      ev ? catDot(ev.cat) : null,
      "e" + e,
    );
  }

  function findingItem(f, severity, title) {
    const clickable = f.events.length && state.g;
    return h(
      "li",
      { class: "finding " + severity },
      clickable
        ? h("button", {
            class: "finding-text",
            type: "button",
            title: "Show these events in the graph",
            text: f.text,
            onclick: () => focusEvents(f.events, title + ": " + f.text),
          })
        : h("span", { class: "finding-text", text: f.text }),
      f.events.length
        ? h(
            "div",
            { class: "chips" },
            f.events.slice(0, 16).map(eventChip),
            f.events.length > 16 ? h("span", { class: "hint", text: "+" + (f.events.length - 16) }) : null,
          )
        : null,
    );
  }

  function findingList(findings, severity, title) {
    const ul = h("ul", { class: "findings" });
    let shown = 0;
    const more = (n) => {
      const stop = Math.min(findings.length, shown + n);
      const last = ul.lastElementChild;
      if (last && last.classList.contains("more")) last.remove();
      ul.append(...findings.slice(shown, stop).map((f) => findingItem(f, severity, title)));
      shown = stop;
      const rest = findings.length - shown;
      if (rest > 0) {
        const next = Math.min(rest, MAX_LISTED);
        ul.append(
          h(
            "li",
            { class: "more" },
            h("button", {
              class: "link",
              type: "button",
              text: "Show " + fmt(next) + " more" + (rest > next ? " (" + fmt(rest) + " left)" : ""),
              onclick: () => more(MAX_LISTED),
            }),
          ),
        );
      }
    };
    more(FINDINGS_SHOWN);
    return ul;
  }

  // Evidence is a Rust `Debug` struct (`Name { field: value, ... }`); flat ones become fields.
  function evidenceView(text) {
    const m = /^\s*[A-Za-z_]\w*\s*\{\s*(.*?)\s*\}\s*$/s.exec(text);
    const fields = m ? m[1].split(/,\s*/).map((p) => /^(\w+):\s*([^{}()[\]]+)$/.exec(p)) : [];
    if (!fields.length || fields.some((f) => !f)) return h("div", { class: "evidence raw", text });
    return h(
      "div",
      { class: "evidence", title: text },
      fields.map(([, k, v]) =>
        h("span", { class: "ev-field" }, h("span", { class: "k", text: k.replace(/_/g, " ") }), h("span", { class: "v", text: v })),
      ),
    );
  }

  function flashCheck(i) {
    const node = byId("check-" + i);
    if (!node) return;
    node.scrollIntoView({ block: "nearest", behavior: "smooth" });
    node.classList.add("flash");
    setTimeout(() => node.classList.remove("flash"), 900);
  }

  function verdictCard(doc) {
    if (!doc.conclusion && !doc.events) return null;
    const c = doc.conclusion;
    const status = c ? c.status : "unchecked";
    const checks = doc.checks || [];
    const passed = checks.filter((k) => k.verdict === "pass").length;
    const sub = [checks.length ? passed + " of " + checks.length + " checks pass" : "analysis stage only: the graph checks were not run"];
    if (doc.terminal) sub.push("trace " + doc.terminal.kind);
    const iconName = FAILING.includes(status)
      ? "cross"
      : { "race-free": "check", unsupported: "alert", unknown: "question", error: "alert" }[status] || "minus";
    return h(
      "div",
      { class: "verdict-card " + status },
      h(
        "div",
        { class: "verdict-top" },
        h("span", { class: "verdict-icon" }, icon(iconName)),
        h(
          "div",
          null,
          h("div", { class: "verdict-title", text: STATUS_NAME[status] }),
          h("div", { class: "verdict-sub", text: sub.join(" · ") }),
        ),
      ),
      c && c.reasons.length ? h("ul", null, c.reasons.map((r) => h("li", { text: r }))) : null,
      checks.length
        ? h(
            "div",
            { class: "check-strip" },
            checks.map((k, i) =>
              h("button", {
                class: "strip-seg " + k.verdict,
                type: "button",
                title: k.name + ": " + k.verdict,
                "aria-label": k.name + ": " + k.verdict,
                onclick: () => flashCheck(i),
              }),
            ),
          )
        : null,
    );
  }

  function checkCard(c, i) {
    const severity = c.verdict === "fail" ? "fail" : "unknown";
    const events = c.findings.length > 1 ? [...new Set(c.findings.flatMap((f) => f.events))].sort((x, y) => x - y) : [];
    return h(
      "li",
      { class: "check " + c.verdict, id: "check-" + i },
      h(
        "div",
        { class: "check-head" },
        h("span", { class: "verdict " + c.verdict, text: c.verdict }),
        h("span", { class: "check-name" }, c.name, h("span", { class: "algorithm", text: c.algorithm })),
      ),
      c.evidence ? evidenceView(c.evidence) : null,
      c.findings.length ? findingList(c.findings, severity, c.name) : null,
      events.length > 1 && state.g
        ? h(
            "div",
            { class: "check-actions" },
            h(
              "button",
              {
                class: "btn small",
                type: "button",
                title: "Step through every event of these findings",
                onclick: () => focusEvents(events, c.name + ": every finding"),
              },
              icon("target"),
              "Focus all " + fmt(events.length) + " events",
            ),
          )
        : null,
    );
  }

  function renderChecks() {
    const doc = state.doc;
    const parts = [];
    if (doc.error) {
      const status = INDEX[state.runIndex].status;
      parts.push(
        section(
          "Execution",
          h(
            "div",
            { class: "callout " + (status === "unsupported" ? "warn" : "bad") },
            h("strong", { text: STATUS_NAME[status] + ": the execution never started." }),
            h("pre", { text: doc.error }),
          ),
        ),
      );
    }
    parts.push(verdictCard(doc));
    if (doc.terminal && doc.terminal.notes.length) {
      const t = doc.terminal;
      parts.push(
        section(
          titled(t.kind === "stuck" ? "Blocked threads" : "Trace " + t.kind, t.notes.length),
          h("ul", { class: "findings" }, t.notes.map((n) => findingItem(n, "stuck", "trace " + t.kind))),
        ),
      );
    }
    if (doc.checks) {
      parts.push(section(titled("Checks", doc.checks.length), h("ol", { class: "checks" }, doc.checks.map(checkCard))));
    }
    if (doc.launch) {
      const l = doc.launch;
      parts.push(
        section(
          "Launch",
          h(
            "dl",
            { class: "kv" },
            h("dt", { text: "block" }),
            h("dd", { text: l.block.join(" × ") }),
            h("dt", { text: "grid" }),
            h("dd", { text: l.grid.join(" × ") }),
            h("dt", { text: "targets" }),
            h("dd", { text: l.targets.join(", ") || "none" }),
          ),
        ),
      );
      if (l.assumptions.length) {
        parts.push(section(titled("Assumptions", l.assumptions.length), h("ul", { class: "assumptions" }, l.assumptions.map((a) => h("li", { text: a })))));
      }
    }
    fill(byId("tab-checks"), ...parts);
  }

  function instructionOf(ev) {
    return ev.pc != null ? state.doc.instructions[ev.pc] || null : null;
  }

  function edgeList(title, indices, endpoint, arrow) {
    if (!indices.length) return null;
    const doc = state.doc;
    return section(
      titled(title, indices.length),
      h(
        "ul",
        { class: "edge-list" },
        indices.slice(0, MAX_LISTED).map((i) => {
          const edge = doc.edges[i];
          const other = edge[endpoint];
          return h(
            "li",
            null,
            h("span", { class: "edge-swatch " + edge[2], "aria-hidden": "true" }),
            h("span", { class: "edge-kind", text: edge[2] }),
            h("span", { class: "arrow", text: arrow }),
            eventChip(other),
            h("span", { class: "edge-label", text: doc.events[other].label, title: doc.events[other].label }),
          );
        }),
        indices.length > MAX_LISTED ? h("li", { class: "hint", text: "and " + fmt(indices.length - MAX_LISTED) + " more" }) : null,
      ),
    );
  }

  // PTX highlighting by token class: the first word of a statement is its opcode, a dotted
  // word before it a directive and after it a modifier.
  const PTX_TOKENS =
    /(\/\/.*$|\/\*.*?\*\/)|("(?:[^"\\]|\\.)*")|(@!?%?[A-Za-z_$][\w$]*)|(%[A-Za-z_$][\w$.]*)|(\.[A-Za-z_][\w:]*)|(0[xX][0-9a-fA-F]+|0[fFdD][0-9a-fA-F]{8,16}|\d+(?:\.\d+)?)|([A-Za-z_$][\w$]*)/g;
  function highlight(line) {
    const out = [];
    let last = 0;
    let opSeen = false;
    let declaration = false;
    const label = /^(\s*)([A-Za-z_$][\w$]*):/.exec(line);
    if (label) {
      out.push(label[1], h("span", { class: "syn-label", text: label[2] + ":" }));
      last = label[0].length;
    }
    PTX_TOKENS.lastIndex = last;
    for (let m; (m = PTX_TOKENS.exec(line)); ) {
      if (m.index > last) {
        const gap = line.slice(last, m.index);
        out.push(gap);
        if (/[;{}]/.test(gap)) opSeen = declaration = false;
      }
      let cls = null;
      if (m[1]) cls = "syn-comment";
      else if (m[2]) cls = "syn-str";
      else if (m[3]) cls = "syn-pred";
      else if (m[4]) cls = "syn-reg";
      else if (m[5]) {
        cls = opSeen ? "syn-mod" : "syn-dir";
        if (!opSeen) declaration = true;
      } else if (m[6]) cls = "syn-num";
      else if (!opSeen && !declaration) {
        cls = "syn-op";
        opSeen = true;
      }
      out.push(cls ? h("span", { class: cls, text: m[0] }) : m[0]);
      last = m.index + m[0].length;
    }
    if (last < line.length) out.push(line.slice(last));
    return out.length ? out : [" "];
  }

  function sourceExcerpt(line) {
    const lines = state.doc.source.split("\n");
    const lo = Math.max(1, line - 3);
    const hi = Math.min(lines.length, line + 3);
    const rows = [];
    for (let n = lo; n <= hi; n++) {
      rows.push(
        h(
          "div",
          { class: "src-line" + (n === line ? " current" : "") },
          h("span", { class: "ln", text: n }),
          h("span", { class: "code" }, highlight(lines[n - 1] || "")),
        ),
      );
    }
    return h("div", { class: "source excerpt" }, rows);
  }

  function renderEvent() {
    const body = byId("tab-event");
    const doc = state.doc;
    const e = state.selected;
    if (!state.g || e < 0) {
      fill(body,
        h(
          "div",
          { class: "empty-hint" },
          h("strong", { text: "No event selected" }),
          state.g
            ? "Click an event in the graph, an event chip of a finding, or a source line. The arrow keys then walk the graph."
            : "This run recorded no graph.",
        ),
      );
      return;
    }
    const g = state.g;
    const ev = doc.events[e];
    const lane = doc.lanes[ev.lane];
    const spec = CATEGORIES[ev.cat] || CATEGORIES.exit;
    const ins = instructionOf(ev);
    const rows = [];
    for (const [k, v] of [["lane", lane.label], ["step", String(g.row[e])]].concat(doc.info(ev))) {
      rows.push(h("dt", { text: k }), h("dd", { text: v }));
    }
    if (ins) {
      rows.push(
        h("dt", { text: "instruction" }),
        h(
          "dd",
          null,
          "pc " + ev.pc + " · " + ins.kind,
          ins.line != null ? " · " : null,
          ins.line != null
            ? h("button", {
                class: "link",
                type: "button",
                text: "line " + ins.line,
                onclick: () => {
                  setTab("source");
                  scrollSourceTo(ins.line);
                },
              })
            : null,
        ),
      );
    }
    const prev = g.prevInLane[e];
    const next = g.nextInLane[e];
    const findings = g.findingsOf.get(e) || [];
    fill(body,
      h(
        "div",
        { class: "event-card" },
        h(
          "div",
          { class: "event-title" },
          swatch(ev.cat, 18),
          h("span", { class: "event-id", text: "e" + e }),
          h("span", { class: "cat-name", text: spec.name }),
        ),
        h("div", { class: "event-label", text: ev.label }),
        h("div", { class: "event-where", text: lane.label + " · step " + g.row[e] + (ins ? " · " + ins.kind : "") }),
        h(
          "div",
          { class: "lane-nav" },
          h(
            "button",
            { class: "btn", type: "button", disabled: prev < 0, title: "Previous event in this lane", onclick: () => select(prev, { center: true }) },
            icon("up"),
            "Previous",
            h("kbd", { text: "↑" }),
          ),
          h(
            "button",
            { class: "btn", type: "button", disabled: next < 0, title: "Next event in this lane", onclick: () => select(next, { center: true }) },
            icon("down"),
            "Next",
            h("kbd", { text: "↓" }),
          ),
        ),
      ),
      findings.length
        ? section(
            titled("Findings", findings.length),
            h(
              "ul",
              { class: "findings" },
              findings.map((f) =>
                h("li", { class: "finding " + f.severity }, h("span", { class: "finding-title", text: f.title }), h("span", { class: "finding-text", text: f.text })),
              ),
            ),
          )
        : null,
      section("Details", h("dl", { class: "kv" }, rows)),
      ins && ins.line != null ? section("Source", sourceExcerpt(ins.line)) : null,
      edgeList("Incoming edges", g.incoming[e], 0, "←"),
      edgeList("Outgoing edges", g.outgoing[e], 1, "→"),
    );
  }

  let sourceBuiltFor = -1;
  function renderSource() {
    const body = byId("tab-source");
    const doc = state.doc;
    if (sourceBuiltFor !== state.runIndex) {
      sourceBuiltFor = state.runIndex;
      const lineEvents = state.g ? state.g.lineEvents : new Map();
      const lines = (doc.source || "").split("\n");
      fill(body,
        h("p", {
          class: "hint",
          text: lineEvents.size ? "Click a highlighted line to step through the events its instruction produced." : "No event maps to a source line.",
        }),
        h(
          "div",
          { class: "source full" },
          lines.map((text, i) => {
            const n = i + 1;
            const events = lineEvents.get(n);
            return h(
              events ? "button" : "div",
              {
                class: "src-line" + (events ? " has-events" : ""),
                type: events ? "button" : null,
                "data-line": n,
                onclick: events ? () => focusEvents(events, "line " + n + ": " + text.trim()) : null,
              },
              h("span", { class: "ln", text: n }),
              h("span", { class: "code" }, highlight(text)),
              events ? h("span", { class: "count", text: fmt(events.length) }) : null,
            );
          }),
        ),
      );
    }
    updateSourceHighlight();
  }

  function updateSourceHighlight() {
    const body = byId("tab-source");
    for (const l of body.querySelectorAll(".src-line.current")) l.classList.remove("current");
    if (state.selected < 0 || !state.doc.events) return;
    const ins = instructionOf(state.doc.events[state.selected]);
    if (!ins || ins.line == null) return;
    const node = body.querySelector('.src-line[data-line="' + ins.line + '"]');
    if (node) node.classList.add("current");
  }

  function scrollSourceTo(line) {
    const node = byId("tab-source").querySelector('.src-line[data-line="' + line + '"]');
    if (node) node.scrollIntoView({ block: "center" });
  }

  // ---------------------------------------------------------------------------------------
  // Empty states: the overview and a run that never started
  // ---------------------------------------------------------------------------------------

  function shortcutList() {
    return h(
      "dl",
      { class: "shortcuts" },
      SHORTCUTS.map((row) =>
        row.length === 1
          ? h("div", { class: "sub", text: row[0] })
          : [h("dt", null, row[0].map((k) => h("kbd", { text: k }))), h("dd", { text: row[1] })],
      ),
    );
  }

  function grammar() {
    return h(
      "div",
      { class: "grammar" },
      Object.keys(CATEGORIES).map((cat) =>
        h("span", { class: "legend-item" }, swatch(cat, 13), h("span", { class: "name", text: CATEGORIES[cat].name })),
      ),
      Object.entries(EDGES).map(([kind, spec]) =>
        h("span", { class: "legend-item" }, h("span", { class: "edge-swatch " + kind }), h("span", { class: "name", text: spec.name + " edge" })),
      ),
      markItems(null),
    );
  }

  function renderWelcome() {
    const counts = statusCounts(INDEX.keys());
    const suites = new Map();
    INDEX.forEach((m, i) => {
      if (!suites.has(m.suite)) suites.set(m.suite, []);
      suites.get(m.suite).push(i);
    });
    fill(byId("run-header"),
      h("div", { class: "crumbs" }, h("h1", { text: "Overview" })),
      h(
        "div",
        { class: "facts" },
        h("span", { class: "fact" }, h("span", { class: "v", text: fmt(INDEX.length) }), h("span", { class: "k", text: " recorded runs" })),
        h("span", { class: "fact" }, h("span", { class: "v", text: fmt(suites.size) }), h("span", { class: "k", text: " suites" })),
      ),
    );
    fill(byId("toolbar"));
    byId("legend").hidden = true;
    byId("view-controls").hidden = true;
    byId("minimap-box").hidden = true;
    byId("focus-bar").hidden = true;
    byId("main").classList.add("no-graph");
    showMessage(null);
    for (const body of document.querySelectorAll(".tab-body")) fill(body);
    fill(byId("tab-checks"),
      h("div", { class: "empty-hint" }, h("strong", { text: "No run open" }), "Pick a test on the left to see its verdict, the seven checks and their findings."),
    );
    updateBadges();
    if (!INDEX.length) {
      showEmptyState(
        h(
          "div",
          { class: "overview narrow" },
          h(
            "div",
            { class: "error-card" },
            h("span", { class: "error-icon" }, icon("alert")),
            h("h2", { text: "No runs were recorded" }),
            h("p", { text: "Run `just viz` to record every volta_bench test and rebuild this page." }),
          ),
        ),
      );
      return;
    }
    const pct = (n) => {
      const p = (100 * n) / INDEX.length;
      return (p >= 10 || p === 0 ? Math.round(p) : p.toFixed(1)) + "%";
    };
    const failing = [...INDEX.keys()].filter((i) => FAILING.includes(INDEX[i].status));
    showEmptyState(
      h(
        "div",
        { class: "overview" },
        h(
          "div",
          { class: "hero" },
          h("h2", { text: "Volta event graphs" }),
          h("p", {
            text:
              "Each run is one candidate execution of a kernel, recorded by a test. Open one to see its event graph lane by lane, " +
              "the verdict of the seven graph checks with their findings resolved to events, and the PTX source behind every event.",
          }),
        ),
        h(
          "div",
          { class: "stat-grid" },
          STATUSES.filter(([s]) => counts[s]).map(([s, name]) =>
            h(
              "button",
              { class: "stat", type: "button", title: "List only " + name.toLowerCase() + " runs", onclick: () => setStatuses(new Set([s])) },
              h("span", { class: "stat-name" }, h("span", { class: "dot " + s }), name),
              h("span", { class: "stat-value", text: fmt(counts[s]) }),
              h("span", { class: "stat-share", text: pct(counts[s]) + " of runs" }),
            ),
          ),
        ),
        h(
          "div",
          { class: "ov-grid" },
          h(
            "section",
            { class: "card" },
            h("h3", { text: "Suites" }),
            h(
              "table",
              { class: "suite-table" },
              h(
                "tbody",
                null,
                [...suites].map(([suite, items]) =>
                  h(
                    "tr",
                    null,
                    h("td", null, h("button", { class: "link", type: "button", text: suiteName(suite), onclick: () => revealSuite(suite) })),
                    h("td", { class: "bar-cell" }, statusBar(statusCounts(items), "mini-bar")),
                    h("td", { class: "num", text: fmt(items.length) }),
                  ),
                ),
              ),
            ),
          ),
          failing.length
            ? h(
                "section",
                { class: "card" },
                h("h3", { text: "Race conditions, failed checks and deadlocks" }),
                h(
                  "ul",
                  { class: "quick-list" },
                  failing.slice(0, 12).map((i) =>
                    h(
                      "li",
                      null,
                      h(
                        "a",
                        { href: "#" + INDEX[i].key, title: INDEX[i].test + "\n" + STATUS_NAME[INDEX[i].status] },
                        h("span", { class: "dot " + INDEX[i].status }),
                        h("span", { class: "test-name" }, breakable(INDEX[i].test.replace(/^test_/, ""))),
                        h("span", { class: "suite-tag", text: suiteName(INDEX[i].suite) }),
                      ),
                    ),
                  ),
                  failing.length > 12
                    ? h(
                        "li",
                        { class: "more" },
                        h("button", {
                          class: "link",
                          type: "button",
                          text: "List all " + fmt(failing.length) + " of them",
                          onclick: () => setStatuses(new Set(FAILING)),
                        }),
                      )
                    : null,
                ),
              )
            : null,
        ),
        h(
          "section",
          { class: "card" },
          h("h3", { text: "Reading a graph" }),
          h("p", {
            text:
              "Columns are lanes: one per thread, one per thread's async operations and one per synchronization object, grouped by warp. " +
              "Rows are steps: an event sits below its lane predecessor and below the source of every typed edge into it.",
          }),
          grammar(),
        ),
        h("section", { class: "card" }, h("h3", { text: "Keyboard and mouse" }), shortcutList()),
      ),
    );
  }

  function renderNotStarted() {
    const doc = state.doc;
    const unsupported = INDEX[state.runIndex].status === "unsupported";
    showEmptyState(
      h(
        "div",
        { class: "overview narrow" },
        h(
          "div",
          { class: "error-card" },
          h("span", { class: "error-icon" }, icon("alert")),
          h("h2", { text: unsupported ? "Unsupported: the kernel cannot be lowered" : "Error: the execution never started" }),
          h("p", {
            text: unsupported
              ? "Lowering rejected a construct Volta does not model, so the execution never started and this run " +
                "recorded no event graph."
              : "The analysis stopped before the first instruction ran (no such kernel or an invalid launch " +
                "configuration), so this run recorded no event graph.",
          }),
          h("pre", { class: "error-text", text: doc.error }),
          doc.source ? h("button", { class: "btn primary", type: "button", onclick: () => setTab("source") }, "Show the PTX source") : null,
        ),
      ),
    );
  }

  function openHelp() {
    fill(byId("help-body"), shortcutList());
    byId("help").hidden = false;
    byId("help-close").focus();
  }

  function closeHelp() {
    byId("help").hidden = true;
  }

  // ---------------------------------------------------------------------------------------
  // Selection and view
  // ---------------------------------------------------------------------------------------

  function select(e, { center = false, tab = true } = {}) {
    state.selected = e;
    if (e >= 0 && state.g) {
      const lane = state.doc.lanes[state.doc.events[e].lane];
      if (state.colOf[state.doc.events[e].lane] < 0) {
        state.threadFilter = null;
        if (lane.kind === "async") state.showAsync = true;
        if (lane.kind === "object") state.showObjects = true;
        applyLanes();
        renderToolbar();
      }
      if (center) centerOn(e);
    }
    if (tab && e >= 0) setTab("event");
    else if (state.tab === "event") renderEvent();
    else if (state.tab === "source") updateSourceHighlight();
    updateBadges();
    draw();
  }

  // The event nearest in row to `e` in the closest visible lane in direction `d`.
  function neighborEvent(e, d) {
    const g = state.g;
    const col = state.colOf[state.doc.events[e].lane];
    const row = g.row[e];
    for (let c = col + d; c >= 0 && c < state.cols.length; c += d) {
      for (let off = 0; off < g.rows; off++) {
        for (const r of off ? [row - off, row + off] : [row]) {
          if (r < 0 || r >= g.rows) continue;
          const found = state.cells.get(c * g.rows + r);
          if (found != null) return found;
        }
      }
    }
    return -1;
  }

  function walk(key) {
    const g = state.g;
    const e = state.selected;
    let next = -1;
    if (key === "ArrowUp") next = g.prevInLane[e];
    else if (key === "ArrowDown") next = g.nextInLane[e];
    else next = neighborEvent(e, key === "ArrowLeft" ? -1 : 1);
    if (next >= 0) select(next, { center: true, tab: state.tab === "event" });
  }

  function centerOn(e) {
    const canvas = byId("graph");
    const W = canvas.clientWidth;
    const H = canvas.clientHeight - HEADER_H;
    const v = state.view;
    const col = state.colOf[state.doc.events[e].lane];
    const row = state.g.row[e];
    const x = v.tx + (col + 0.5) * v.sx;
    const y = v.ty + (row + 0.5) * v.sy;
    const margin = 40;
    if (v.sx >= 24 && v.sy >= 12 && x > GUTTER_W + margin && x < W - margin && y > margin && y < H - margin) {
      return;
    }
    v.sx = Math.max(v.sx, 24);
    v.sy = Math.max(v.sy, 12);
    v.tx = (GUTTER_W + W) / 2 - (col + 0.5) * v.sx;
    v.ty = H / 2 - (row + 0.5) * v.sy;
    clampView();
  }

  function fit() {
    if (!state.g) {
      draw();
      return;
    }
    const canvas = byId("graph");
    const W = Math.max(100, canvas.clientWidth - GUTTER_W);
    const H = Math.max(100, canvas.clientHeight - HEADER_H);
    const cols = Math.max(1, state.cols.length);
    const rows = Math.max(1, state.g.rows);
    const v = state.view;
    v.sx = Math.min(240, Math.max(4, (W - 24) / cols));
    v.sy = Math.min(34, Math.max(1.5, (H - 24) / rows));
    v.tx = GUTTER_W + Math.max(12, (W - cols * v.sx) / 2);
    v.ty = 12;
    draw();
  }

  function clampView() {
    const canvas = byId("graph");
    const W = canvas.clientWidth;
    const H = canvas.clientHeight - HEADER_H;
    const v = state.view;
    const width = state.cols.length * v.sx;
    const height = (state.g ? state.g.rows : 1) * v.sy;
    v.tx = Math.min(W * 0.8, Math.max(v.tx, W * 0.2 - width));
    v.ty = Math.min(H * 0.8, Math.max(v.ty, H * 0.2 - height));
  }

  function zoomAt(mx, my, fx, fy) {
    const v = state.view;
    const nsx = Math.min(600, Math.max(1, v.sx * fx));
    const nsy = Math.min(200, Math.max(0.5, v.sy * fy));
    const y = my - HEADER_H;
    v.tx = mx - ((mx - v.tx) * nsx) / v.sx;
    v.ty = y - ((y - v.ty) * nsy) / v.sy;
    v.sx = nsx;
    v.sy = nsy;
    clampView();
    draw();
  }

  function zoomBy(f) {
    const canvas = byId("graph");
    zoomAt((GUTTER_W + canvas.clientWidth) / 2, HEADER_H + (canvas.clientHeight - HEADER_H) / 2, f, f);
  }

  // The visible part of the graph as fractions of its lanes and rows.
  function viewportBox() {
    const canvas = byId("graph");
    const v = state.view;
    const cols = Math.max(1, state.cols.length);
    const rows = Math.max(1, state.g.rows);
    const left = (GUTTER_W - v.tx) / v.sx / cols;
    const right = (canvas.clientWidth - v.tx) / v.sx / cols;
    const top = -v.ty / v.sy / rows;
    const bottom = (canvas.clientHeight - HEADER_H - v.ty) / v.sy / rows;
    return { left, right, top, bottom, whole: left <= 0 && right >= 1 && top <= 0 && bottom >= 1 };
  }

  // ---------------------------------------------------------------------------------------
  // Painting
  // ---------------------------------------------------------------------------------------

  function shapePath(ctx, shape, x, y, r) {
    switch (shape) {
      case "circle":
      case "ring":
        ctx.moveTo(x + r, y);
        ctx.arc(x, y, r, 0, Math.PI * 2);
        break;
      case "tri-down":
      case "tri-down-open":
        ctx.moveTo(x - r * 1.15, y - r * 0.85);
        ctx.lineTo(x + r * 1.15, y - r * 0.85);
        ctx.lineTo(x, y + r * 1.05);
        ctx.closePath();
        break;
      case "tri-up":
        ctx.moveTo(x - r * 1.15, y + r * 0.85);
        ctx.lineTo(x + r * 1.15, y + r * 0.85);
        ctx.lineTo(x, y - r * 1.05);
        ctx.closePath();
        break;
      case "diamond":
        ctx.moveTo(x, y - r * 1.3);
        ctx.lineTo(x + r * 1.3, y);
        ctx.lineTo(x, y + r * 1.3);
        ctx.lineTo(x - r * 1.3, y);
        ctx.closePath();
        break;
      case "square":
      case "square-open":
        ctx.rect(x - r * 0.9, y - r * 0.9, r * 1.8, r * 1.8);
        break;
      case "bar":
        ctx.rect(x - r * 1.3, y - r * 0.45, r * 2.6, r * 0.9);
        break;
      case "cross":
        ctx.moveTo(x - r, y - r);
        ctx.lineTo(x + r, y + r);
        ctx.moveTo(x + r, y - r);
        ctx.lineTo(x - r, y + r);
        break;
    }
  }

  function paintShape(ctx, shape, color, r) {
    if (OPEN_SHAPES.has(shape)) {
      ctx.strokeStyle = color;
      ctx.lineWidth = Math.max(1, r * 0.4);
      ctx.stroke();
    } else {
      ctx.fillStyle = color;
      ctx.fill();
    }
  }

  // A canvas-colored outline (and, for open shapes, interior) that lifts events off the edges.
  function paintHalo(ctx, shape, r) {
    const open = OPEN_SHAPES.has(shape);
    if (open && shape !== "cross") {
      ctx.fillStyle = colors["--canvas"];
      ctx.fill();
    }
    ctx.strokeStyle = colors["--canvas"];
    ctx.lineWidth = (open ? Math.max(1, r * 0.4) : 0) + 3;
    ctx.stroke();
  }

  const fade = (n) => (n <= CLEAR_EDGES ? 1 : Math.max(0.2, Math.sqrt(CLEAR_EDGES / n)));

  function rulerStep(sy) {
    for (const k of [1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000]) {
      if (k * sy >= 22) return k;
    }
    return 100000;
  }

  let framePending = false;
  function draw() {
    if (framePending) return;
    framePending = true;
    requestAnimationFrame(() => {
      framePending = false;
      paint();
      paintMinimap();
    });
  }

  function resizeCanvas() {
    const canvas = byId("graph");
    const dpr = window.devicePixelRatio || 1;
    const w = canvas.clientWidth;
    const hgt = canvas.clientHeight;
    if (canvas.width !== Math.round(w * dpr) || canvas.height !== Math.round(hgt * dpr)) {
      canvas.width = Math.round(w * dpr);
      canvas.height = Math.round(hgt * dpr);
    }
  }

  function paint() {
    const canvas = byId("graph");
    const ctx = canvas.getContext("2d");
    const dpr = window.devicePixelRatio || 1;
    const W = canvas.clientWidth;
    const H = canvas.clientHeight;
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    ctx.fillStyle = colors["--canvas"];
    ctx.fillRect(0, 0, W, H);
    const g = state.g;
    const doc = state.doc;
    if (!g || !doc.events.length) return;

    const v = state.view;
    const X = (col) => v.tx + (col + 0.5) * v.sx;
    const Y = (row) => HEADER_H + v.ty + (row + 0.5) * v.sy;
    const cols = state.cols.length;
    const c0 = Math.max(0, Math.floor((GUTTER_W - v.tx) / v.sx) - 1);
    const c1 = Math.min(cols - 1, Math.ceil((W - v.tx) / v.sx) + 1);
    const r0 = Math.max(0, Math.floor(-v.ty / v.sy) - 1);
    const r1 = Math.min(g.rows - 1, Math.ceil((H - HEADER_H - v.ty) / v.sy) + 1);
    const r = Math.max(1.2, Math.min(v.sx * 0.3, v.sy * 0.36, 7));
    const yTop = Math.max(HEADER_H, Y(0) - v.sy / 2);
    const yBottom = Math.min(H, Y(g.rows - 1) + v.sy / 2);
    const sel = state.selected;
    const selCol = sel >= 0 ? state.colOf[doc.events[sel].lane] : -1;
    const tick = rulerStep(v.sy);

    ctx.save();
    ctx.beginPath();
    ctx.rect(GUTTER_W, HEADER_H, W - GUTTER_W, H - HEADER_H);
    ctx.clip();

    // Lane backgrounds: shaded non-thread lanes and the selected event's lane.
    if (v.sx > 6) {
      ctx.fillStyle = colors["--lane-fill"];
      for (let c = c0; c <= c1; c++) {
        if (doc.lanes[state.cols[c]].kind === "thread") continue;
        ctx.fillRect(v.tx + c * v.sx + 1, yTop, v.sx - 2, yBottom - yTop);
      }
    }
    if (selCol >= 0) {
      ctx.fillStyle = colors["--accent-soft"];
      ctx.globalAlpha = 0.5;
      ctx.fillRect(v.tx + selCol * v.sx, HEADER_H, v.sx, H - HEADER_H);
      ctx.globalAlpha = 1;
    }

    // Row guides at the ruler's ticks, lane guides, and a stronger rule where a warp begins.
    ctx.lineWidth = 1;
    ctx.strokeStyle = colors["--row-guide"];
    ctx.beginPath();
    const xl = Math.max(GUTTER_W, v.tx);
    const xr = Math.min(W, v.tx + cols * v.sx);
    for (let row = Math.ceil(r0 / tick) * tick; row <= r1; row += tick) {
      const y = Math.round(Y(row)) + 0.5;
      ctx.moveTo(xl, y);
      ctx.lineTo(xr, y);
    }
    ctx.stroke();
    ctx.strokeStyle = colors["--lane-guide"];
    ctx.beginPath();
    for (let c = c0; c <= c1; c++) {
      const x = Math.round(X(c)) + 0.5;
      ctx.moveTo(x, yTop);
      ctx.lineTo(x, yBottom);
    }
    ctx.stroke();
    ctx.strokeStyle = colors["--lane-sep"];
    ctx.beginPath();
    for (let c = Math.max(1, c0); c <= c1; c++) {
      if (!startsGroup(c)) continue;
      const sep = Math.round(v.tx + c * v.sx) + 0.5;
      ctx.moveTo(sep, HEADER_H);
      ctx.lineTo(sep, H);
    }
    ctx.stroke();

    const incident = new Set();
    if (sel >= 0) {
      for (const i of g.incoming[sel]) incident.add(i);
      for (const i of g.outgoing[sel]) incident.add(i);
    }
    const dimmed = sel >= 0 || state.highlightCat != null;
    const arrows = v.sx >= 36 && v.sy >= 14;

    const edgeEnds = (i) => {
      const [from, to] = doc.edges[i];
      const cf = state.colOf[doc.events[from].lane];
      const ct = state.colOf[doc.events[to].lane];
      if (cf < 0 || ct < 0) return null;
      const x1 = X(cf);
      const y1 = Y(g.row[from]);
      const x2 = X(ct);
      const y2 = Y(g.row[to]);
      if (Math.max(y1, y2) < HEADER_H || Math.min(y1, y2) > H) return null;
      if (Math.max(x1, x2) < GUTTER_W || Math.min(x1, x2) > W) return null;
      return [x1, y1, x2, y2, cf === ct];
    };
    const edgePath = (ends) => {
      const [x1, y1, x2, y2, sameLane] = ends;
      ctx.moveTo(x1, y1);
      if (sameLane) {
        const bulge = Math.min(v.sx * 0.45, 40);
        ctx.quadraticCurveTo(x1 + bulge, (y1 + y2) / 2, x2, y2);
      } else {
        ctx.lineTo(x2, y2);
      }
    };
    const arrowHead = (ends, size) => {
      const [x1, y1, x2, y2, sameLane] = ends;
      const ax = sameLane ? x2 + Math.min(v.sx * 0.45, 40) / 2 : x1;
      const angle = Math.atan2(y2 - (sameLane ? (y1 + y2) / 2 : y1), x2 - ax);
      const tipX = x2 - Math.cos(angle) * (r + 1.5);
      const tipY = y2 - Math.sin(angle) * (r + 1.5);
      ctx.moveTo(tipX, tipY);
      ctx.lineTo(tipX - Math.cos(angle - 0.45) * size, tipY - Math.sin(angle - 0.45) * size);
      ctx.lineTo(tipX - Math.cos(angle + 0.45) * size, tipY - Math.sin(angle + 0.45) * size);
      ctx.closePath();
    };

    // Typed edges: everything first (dimmed while an event is selected), then the
    // selection's own edges on top.
    for (const [kind, spec] of Object.entries(EDGES)) {
      const list = g.edgesByKind[kind];
      if (!list || !state.edgeOn[kind]) continue;
      ctx.strokeStyle = colors[spec.color];
      ctx.fillStyle = colors[spec.color];
      ctx.setLineDash(spec.dash);
      ctx.lineWidth = 1;
      ctx.beginPath();
      const heads = [];
      let drawn = 0;
      for (const i of list) {
        if (incident.has(i)) continue;
        const ends = edgeEnds(i);
        if (!ends) continue;
        edgePath(ends);
        drawn++;
        if (arrows) heads.push(ends);
      }
      ctx.globalAlpha = (dimmed ? 0.16 : 1) * fade(drawn);
      ctx.stroke();
      if (heads.length) {
        ctx.setLineDash([]);
        ctx.beginPath();
        for (const ends of heads) arrowHead(ends, 5);
        ctx.fill();
      }
      ctx.globalAlpha = 1;
    }
    ctx.setLineDash([]);

    // Program order inside each thread lane.
    ctx.strokeStyle = colors["--e-po"];
    ctx.lineWidth = Math.max(1, Math.min(2, v.sx * 0.06));
    ctx.beginPath();
    for (let e = 0; e < doc.events.length; e++) {
      const p = g.prevInLane[e];
      if (p < 0) continue;
      const laneIx = doc.events[e].lane;
      if (doc.lanes[laneIx].kind !== "thread") continue;
      const c = state.colOf[laneIx];
      if (c < c0 || c > c1) continue;
      if (g.row[e] < r0 || g.row[p] > r1) continue;
      const x = X(c);
      ctx.moveTo(x, Y(g.row[p]));
      ctx.lineTo(x, Y(g.row[e]));
    }
    ctx.stroke();

    for (const i of incident) {
      const kind = doc.edges[i][2];
      if (!state.edgeOn[kind]) continue;
      const ends = edgeEnds(i);
      if (!ends) continue;
      const spec = EDGES[kind] || EDGES.contribute;
      ctx.strokeStyle = colors[spec.color];
      ctx.fillStyle = colors[spec.color];
      ctx.setLineDash(spec.dash);
      ctx.lineWidth = 2.25;
      ctx.beginPath();
      edgePath(ends);
      ctx.stroke();
      ctx.setLineDash([]);
      ctx.beginPath();
      arrowHead(ends, 7);
      ctx.fill();
    }
    ctx.setLineDash([]);

    // Events, one path per category, lifted off the edges by a halo once they are big enough.
    const visible = (e) => {
      const c = state.colOf[doc.events[e].lane];
      const row = g.row[e];
      return c >= c0 && c <= c1 && row >= r0 && row <= r1 ? c : -1;
    };
    ctx.lineJoin = "round";
    for (const [cat, list] of Object.entries(g.byCategory)) {
      const spec = CATEGORIES[cat] || CATEGORIES.exit;
      const color = colors[spec.color];
      ctx.globalAlpha = state.highlightCat && state.highlightCat !== cat ? 0.12 : 1;
      ctx.beginPath();
      if (r < 2) {
        ctx.fillStyle = color;
        for (const e of list) {
          const c = visible(e);
          if (c >= 0) ctx.fillRect(X(c) - r, Y(g.row[e]) - r, r * 2, r * 2);
        }
        continue;
      }
      for (const e of list) {
        const c = visible(e);
        if (c >= 0) shapePath(ctx, spec.shape, X(c), Y(g.row[e]), r);
      }
      if (r >= 3) paintHalo(ctx, spec.shape, r);
      paintShape(ctx, spec.shape, color, r);
    }
    ctx.globalAlpha = 1;

    // Rings: findings, the focused set, hover and selection.
    const ring = (e, color, width, extra) => {
      const c = visible(e);
      if (c < 0) return;
      ctx.strokeStyle = color;
      ctx.lineWidth = width;
      ctx.beginPath();
      ctx.arc(X(c), Y(g.row[e]), r + extra, 0, Math.PI * 2);
      ctx.stroke();
    };
    for (const [e, sev] of g.severity) {
      ring(e, sev === "fail" ? colors["--bad"] : colors["--warn"], 2, 3);
    }
    if (state.focus) for (const e of state.focus.events) ring(e, colors["--accent"], 2, 5.5);
    if (state.hover >= 0 && state.hover !== sel) ring(state.hover, colors["--hover"], 1.5, 2.5);
    if (sel >= 0) {
      ring(sel, colors["--canvas"], 5, 4);
      ring(sel, colors["--accent"], 3, 4);
    }

    // Inline labels once lanes are wide enough to hold them, read from the visible cells only.
    if (v.sx >= 110 && v.sy >= 13) {
      ctx.font = "11px " + fonts.sans;
      ctx.textBaseline = "middle";
      ctx.lineWidth = 3;
      ctx.strokeStyle = colors["--canvas"];
      const off = r + 8;
      const maxChars = Math.floor((v.sx - off - 6) / 6.1);
      for (let c = c0; c <= c1; c++) {
        for (let row = r0; row <= r1; row++) {
          const e = state.cells.get(c * g.rows + row);
          if (e == null) continue;
          if (state.highlightCat && doc.events[e].cat !== state.highlightCat) continue;
          let label = doc.events[e].label;
          if (label.length > maxChars) label = label.slice(0, Math.max(1, maxChars - 1)) + "…";
          const x = X(c) + off;
          const y = Y(row);
          ctx.strokeText(label, x, y);
          ctx.fillStyle = e === sel ? colors["--text"] : colors["--muted"];
          ctx.fillText(label, x, y);
        }
      }
    }
    ctx.restore();

    const hoverCol = state.hover >= 0 ? state.colOf[doc.events[state.hover].lane] : -1;
    paintRuler(ctx, H, r0, r1, Y, tick, sel >= 0 ? g.row[sel] : -1);
    paintHeader(ctx, W, c0, c1, X, selCol, hoverCol);
  }

  function groupOf(laneIx) {
    const lane = state.doc.lanes[laneIx];
    return lane.kind === "object" ? "sync objects" : "warp " + Math.floor(lane.thread / 32);
  }

  function startsGroup(c) {
    return c > 0 && groupOf(state.cols[c]) !== groupOf(state.cols[c - 1]);
  }

  function pillPath(ctx, x, y, w, hgt) {
    ctx.beginPath();
    if (ctx.roundRect) ctx.roundRect(x, y, w, hgt, hgt / 2);
    else ctx.rect(x, y, w, hgt);
  }

  // The time axis: step numbers at a readable spacing, the selected event's step as a pill.
  function paintRuler(ctx, H, r0, r1, Y, tick, selRow) {
    const v = state.view;
    ctx.save();
    ctx.fillStyle = colors["--header-bg"];
    ctx.fillRect(0, HEADER_H, GUTTER_W, H - HEADER_H);
    ctx.strokeStyle = colors["--border"];
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(GUTTER_W - 0.5, HEADER_H);
    ctx.lineTo(GUTTER_W - 0.5, H);
    ctx.stroke();
    ctx.beginPath();
    ctx.rect(0, HEADER_H, GUTTER_W, H - HEADER_H);
    ctx.clip();
    ctx.font = "10px " + fonts.mono;
    ctx.textAlign = "right";
    ctx.textBaseline = "middle";
    ctx.fillStyle = colors["--muted"];
    ctx.strokeStyle = colors["--lane-sep"];
    ctx.beginPath();
    for (let row = Math.ceil(r0 / tick) * tick; row <= r1; row += tick) {
      const y = Y(row);
      if (y < HEADER_H + 6 || (selRow >= 0 && Math.abs(row - selRow) * v.sy < 14)) continue;
      ctx.fillText(String(row), GUTTER_W - 9, y);
      ctx.moveTo(GUTTER_W - 5, Math.round(y) + 0.5);
      ctx.lineTo(GUTTER_W, Math.round(y) + 0.5);
    }
    ctx.stroke();
    if (selRow >= 0) {
      const y = Y(selRow);
      const text = String(selRow);
      const w = ctx.measureText(text).width + 10;
      ctx.fillStyle = colors["--accent"];
      pillPath(ctx, GUTTER_W - 4 - w, y - 8, w, 16);
      ctx.fill();
      ctx.fillStyle = colors["--on-accent"];
      ctx.fillText(text, GUTTER_W - 9, y + 0.5);
    }
    ctx.restore();
  }

  function paintHeader(ctx, W, c0, c1, X, selCol, hoverCol) {
    const v = state.view;
    const doc = state.doc;
    ctx.save();
    ctx.fillStyle = colors["--header-bg"];
    ctx.fillRect(0, 0, W, HEADER_H);
    ctx.strokeStyle = colors["--border"];
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(0, HEADER_H - 0.5);
    ctx.lineTo(W, HEADER_H - 0.5);
    ctx.moveTo(GUTTER_W - 0.5, 0);
    ctx.lineTo(GUTTER_W - 0.5, HEADER_H);
    ctx.stroke();
    ctx.font = "600 9.5px " + fonts.sans;
    ctx.textAlign = "right";
    ctx.textBaseline = "middle";
    ctx.fillStyle = colors["--muted"];
    ctx.fillText("STEP", GUTTER_W - 9, HEADER_H - 12);
    ctx.textAlign = "left";

    ctx.beginPath();
    ctx.rect(GUTTER_W, 0, W - GUTTER_W, HEADER_H);
    ctx.clip();
    for (const c of new Set([selCol, hoverCol])) {
      if (c < c0 || c > c1) continue;
      ctx.fillStyle = colors["--accent-soft"];
      ctx.fillRect(v.tx + c * v.sx, BAND_H, v.sx, HEADER_H - BAND_H);
    }
    ctx.strokeStyle = colors["--border"];
    ctx.beginPath();
    ctx.moveTo(GUTTER_W, BAND_H - 0.5);
    ctx.lineTo(W, BAND_H - 0.5);
    ctx.stroke();

    // Group bands: each warp's lanes, then the synchronization objects.
    let start = c0;
    for (let c = c0; c <= c1 + 1; c++) {
      if (c <= c1 && (c === start || !startsGroup(c))) continue;
      const x0 = Math.max(GUTTER_W, v.tx + start * v.sx);
      const x1 = Math.min(W, v.tx + c * v.sx);
      const label = groupOf(state.cols[start]);
      ctx.strokeStyle = colors["--border"];
      ctx.beginPath();
      ctx.moveTo(Math.round(v.tx + c * v.sx) + 0.5, 0);
      ctx.lineTo(Math.round(v.tx + c * v.sx) + 0.5, BAND_H);
      ctx.stroke();
      ctx.font = "600 11px " + fonts.sans;
      const width = ctx.measureText(label).width;
      if (x1 - x0 > width + 8) {
        ctx.fillStyle = colors["--muted"];
        ctx.fillText(label, (x0 + x1) / 2 - width / 2, BAND_H / 2);
      }
      start = c;
    }

    // Lane labels: horizontal when they fit, rotated in narrow lanes, and in lanes too narrow
    // for either, rotated on every k-th thread (aligned to warps) plus the marked lanes.
    const space = HEADER_H - BAND_H - 6;
    const marked = (c) => c === selCol || c === hoverCol;
    const laneColor = (c, lane) =>
      marked(c) ? colors["--accent"] : lane.kind === "thread" ? colors["--text"] : colors["--muted"];
    const rotated = (c, label) => {
      ctx.font = (marked(c) ? "600 " : "") + "11px " + fonts.sans;
      while (label.length > 1 && ctx.measureText(label).width > space) label = label.slice(0, -2) + "…";
      ctx.save();
      ctx.translate(X(c), HEADER_H - 4);
      ctx.rotate(-Math.PI / 2);
      ctx.fillText(label, 0, 0);
      ctx.restore();
    };
    let k = 1;
    while (k * v.sx < 15 && k < 4096) k *= 2;
    ctx.strokeStyle = colors["--lane-sep"];
    for (let c = c0; c <= c1; c++) {
      const lane = doc.lanes[state.cols[c]];
      const x = X(c);
      ctx.fillStyle = laneColor(c, lane);
      let label = lane.label;
      if (v.sx >= 56) {
        ctx.font = (marked(c) ? "600 " : "") + "11px " + fonts.sans;
        const max = v.sx - 6;
        while (label.length > 1 && ctx.measureText(label).width > max) label = label.slice(0, -2) + "…";
        const width = ctx.measureText(label).width;
        ctx.fillText(label, x - width / 2, BAND_H + (HEADER_H - BAND_H) / 2);
      } else if (v.sx >= 11) {
        rotated(c, label);
      } else if (marked(c) || (lane.kind === "thread" && lane.thread % k === 0)) {
        rotated(c, label);
        ctx.beginPath();
        ctx.moveTo(Math.round(x) + 0.5, HEADER_H - 3);
        ctx.lineTo(Math.round(x) + 0.5, HEADER_H);
        ctx.stroke();
      }
    }
    ctx.restore();
  }

  // The overview map: every event as a dot of its category's color, findings on top,
  // stretched to the map's box; cached until the lanes or the theme change.
  function miniImage() {
    if (state.mini) return state.mini;
    const g = state.g;
    const doc = state.doc;
    const dpr = window.devicePixelRatio || 1;
    const img = document.createElement("canvas");
    img.width = Math.round(MINI_W * dpr);
    img.height = Math.round(MINI_H * dpr);
    const ctx = img.getContext("2d");
    ctx.scale(dpr, dpr);
    ctx.fillStyle = colors["--canvas"];
    ctx.fillRect(0, 0, MINI_W, MINI_H);
    const cw = MINI_W / Math.max(1, state.cols.length);
    const rh = MINI_H / Math.max(1, g.rows);
    const w = Math.max(0.8, cw * 0.7);
    const hh = Math.max(0.8, rh * 0.8);
    ctx.globalAlpha = 0.85;
    for (const [cat, list] of Object.entries(g.byCategory)) {
      ctx.fillStyle = colors[(CATEGORIES[cat] || CATEGORIES.exit).color];
      for (const e of list) {
        const c = state.colOf[doc.events[e].lane];
        if (c >= 0) ctx.fillRect(c * cw + (cw - w) / 2, g.row[e] * rh + (rh - hh) / 2, w, hh);
      }
    }
    ctx.globalAlpha = 1;
    for (const [e, sev] of g.severity) {
      const c = state.colOf[doc.events[e].lane];
      if (c < 0) continue;
      ctx.fillStyle = sev === "fail" ? colors["--bad"] : colors["--warn"];
      ctx.fillRect(c * cw + cw / 2 - 1.5, g.row[e] * rh + rh / 2 - 1.5, 3, 3);
    }
    state.mini = img;
    return img;
  }

  function paintMinimap() {
    const box = byId("minimap-box");
    const show = !!(ui.minimap && state.g && state.doc.events.length && state.cols.length) && !viewportBox().whole;
    if (box.hidden === show) box.hidden = !show;
    if (!show) return;
    const mini = byId("minimap");
    const dpr = window.devicePixelRatio || 1;
    if (mini.width !== Math.round(MINI_W * dpr)) {
      mini.width = Math.round(MINI_W * dpr);
      mini.height = Math.round(MINI_H * dpr);
    }
    const ctx = mini.getContext("2d");
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    ctx.drawImage(miniImage(), 0, 0, MINI_W, MINI_H);
    const b = viewportBox();
    const x0 = clamp(b.left, 0, 1) * MINI_W;
    const x1 = clamp(b.right, 0, 1) * MINI_W;
    const y0 = clamp(b.top, 0, 1) * MINI_H;
    const y1 = clamp(b.bottom, 0, 1) * MINI_H;
    ctx.fillStyle = colors["--canvas"];
    ctx.globalAlpha = 0.6;
    ctx.beginPath();
    ctx.rect(0, 0, MINI_W, MINI_H);
    ctx.rect(x0, y0, x1 - x0, y1 - y0);
    ctx.fill("evenodd");
    ctx.globalAlpha = 1;
    ctx.strokeStyle = colors["--accent"];
    ctx.lineWidth = 1.5;
    ctx.strokeRect(x0 + 0.75, y0 + 0.75, Math.max(2, x1 - x0 - 1.5), Math.max(2, y1 - y0 - 1.5));
  }

  // ---------------------------------------------------------------------------------------
  // Canvas interaction
  // ---------------------------------------------------------------------------------------

  function hit(mx, my) {
    const g = state.g;
    if (!g || my < HEADER_H || mx < GUTTER_W) return -1;
    const v = state.view;
    const col = Math.floor((mx - v.tx) / v.sx);
    const rowF = (my - HEADER_H - v.ty) / v.sy - 0.5;
    if (col < 0 || col >= state.cols.length) return -1;
    let best = -1;
    let bestD = Infinity;
    const reach = Math.max(8, Math.min(v.sx, v.sy) * 0.5);
    for (let row = Math.floor(rowF) - 1; row <= Math.ceil(rowF) + 1; row++) {
      if (row < 0 || row >= g.rows) continue;
      const e = state.cells.get(col * g.rows + row);
      if (e == null) continue;
      const dx = mx - (v.tx + (col + 0.5) * v.sx);
      const dy = my - (HEADER_H + v.ty + (row + 0.5) * v.sy);
      const d = Math.hypot(dx, dy);
      if (d < bestD && d <= reach) {
        best = e;
        bestD = d;
      }
    }
    return best;
  }

  let tipFor = -1;
  function showTooltip(e, mx, my) {
    const tip = byId("tooltip");
    if (e < 0) {
      tip.hidden = true;
      tipFor = -1;
      return;
    }
    if (e !== tipFor) {
      tipFor = e;
      const doc = state.doc;
      const ev = doc.events[e];
      const ins = instructionOf(ev);
      const findings = state.g.findingsOf.get(e);
      const where = [doc.lanes[ev.lane].label, "step " + state.g.row[e]];
      if (ins) where.push(ins.kind + (ins.line != null ? " · line " + ins.line : ""));
      fill(tip,
        h(
          "div",
          { class: "tip-title" },
          swatch(ev.cat, 12),
          h("strong", { text: "e" + e }),
          h("span", { class: "tip-cat", text: (CATEGORIES[ev.cat] || CATEGORIES.exit).name }),
        ),
        h("div", { class: "tip-label", text: ev.label }),
        h("div", { class: "tip-meta", text: where.join(" · ") }),
        findings
          ? h(
              "div",
              { class: "tip-finding " + findings[0].severity },
              h("strong", { text: findings[0].title }),
              h("span", { text: findings[0].text + (findings.length > 1 ? " (+" + (findings.length - 1) + " more)" : "") }),
            )
          : null,
      );
      tip.hidden = false;
    }
    const wrap = byId("canvas-wrap").getBoundingClientRect();
    const tw = tip.offsetWidth;
    const th = tip.offsetHeight;
    let x = mx + 14;
    let y = my + 14;
    if (x + tw > wrap.width - 4) x = mx - tw - 10;
    if (y + th > wrap.height - 4) y = my - th - 10;
    tip.style.left = Math.max(4, x) + "px";
    tip.style.top = Math.max(4, y) + "px";
  }

  function installCanvas() {
    const canvas = byId("graph");
    let drag = null;
    const local = (ev) => {
      const rect = canvas.getBoundingClientRect();
      return [ev.clientX - rect.left, ev.clientY - rect.top];
    };
    canvas.addEventListener("pointerdown", (ev) => {
      if (ev.button !== 0) return;
      drag = { x: ev.clientX, y: ev.clientY, tx: state.view.tx, ty: state.view.ty, moved: false };
      canvas.setPointerCapture(ev.pointerId);
    });
    canvas.addEventListener("pointermove", (ev) => {
      const [mx, my] = local(ev);
      if (drag) {
        const dx = ev.clientX - drag.x;
        const dy = ev.clientY - drag.y;
        if (!drag.moved && Math.abs(dx) + Math.abs(dy) > 3) {
          drag.moved = true;
          canvas.classList.add("panning");
          showTooltip(-1);
        }
        if (drag.moved) {
          state.view.tx = drag.tx + dx;
          state.view.ty = drag.ty + dy;
          clampView();
          draw();
          return;
        }
      }
      const e = hit(mx, my);
      if (e !== state.hover) {
        state.hover = e;
        canvas.style.cursor = e >= 0 ? "pointer" : "";
        draw();
      }
      showTooltip(e, mx, my);
    });
    canvas.addEventListener("pointerup", (ev) => {
      if (drag && !drag.moved) {
        const [mx, my] = local(ev);
        const e = hit(mx, my);
        if (e >= 0) select(e);
        else if (state.selected >= 0) select(-1, { tab: false });
      }
      drag = null;
      canvas.classList.remove("panning");
    });
    canvas.addEventListener("pointerleave", () => {
      if (state.hover >= 0) {
        state.hover = -1;
        draw();
      }
      showTooltip(-1);
    });
    canvas.addEventListener("dblclick", (ev) => {
      if (!state.g) return;
      const [mx, my] = local(ev);
      if (mx >= GUTTER_W && my >= HEADER_H) zoomAt(mx, my, 2, 2);
    });
    canvas.addEventListener(
      "wheel",
      (ev) => {
        if (!state.g) return;
        ev.preventDefault();
        const [mx, my] = local(ev);
        const scale = ev.deltaMode === 1 ? 16 : 1;
        if (ev.ctrlKey || ev.metaKey) {
          const f = Math.exp(-ev.deltaY * scale * 0.0025);
          zoomAt(mx, my, f, f);
        } else if (ev.altKey) {
          zoomAt(mx, my, 1, Math.exp(-(ev.deltaY || ev.deltaX) * scale * 0.0025));
        } else {
          const dx = ev.shiftKey ? ev.deltaY : ev.deltaX;
          const dy = ev.shiftKey ? 0 : ev.deltaY;
          state.view.tx -= dx * scale;
          state.view.ty -= dy * scale;
          clampView();
          draw();
        }
        showTooltip(-1);
      },
      { passive: false },
    );
    new ResizeObserver(() => {
      resizeCanvas();
      draw();
    }).observe(byId("canvas-wrap"));

    const mini = byId("minimap");
    let steering = false;
    const steer = (ev) => {
      const rect = mini.getBoundingClientRect();
      const nx = clamp((ev.clientX - rect.left) / rect.width, 0, 1);
      const ny = clamp((ev.clientY - rect.top) / rect.height, 0, 1);
      const v = state.view;
      v.tx = (GUTTER_W + canvas.clientWidth) / 2 - nx * state.cols.length * v.sx;
      v.ty = (canvas.clientHeight - HEADER_H) / 2 - ny * state.g.rows * v.sy;
      clampView();
      draw();
    };
    mini.addEventListener("pointerdown", (ev) => {
      if (!state.g || ev.button !== 0) return;
      steering = true;
      mini.setPointerCapture(ev.pointerId);
      steer(ev);
    });
    mini.addEventListener("pointermove", (ev) => {
      if (steering) steer(ev);
    });
    mini.addEventListener("pointerup", () => {
      steering = false;
    });
  }

  // ---------------------------------------------------------------------------------------
  // Shell
  // ---------------------------------------------------------------------------------------

  function applyTheme(theme) {
    if (theme === "light" || theme === "dark") document.documentElement.dataset.theme = theme;
    else delete document.documentElement.dataset.theme;
    const button = byId("theme-toggle");
    fill(button, icon(theme === "light" ? "sun" : theme === "dark" ? "moon" : "auto"));
    const next = { null: "light", light: "dark", dark: "auto" }[theme || null];
    button.title = "Theme: " + (theme || "auto, following the system") + " (click for " + next + ")";
    button.setAttribute("aria-label", button.title);
    readColors();
    tipFor = -1;
    if (state.g) {
      renderLegend();
      if (state.tab === "event") renderEvent();
    } else if (state.runIndex < 0 && !byId("empty-state").hidden) {
      renderWelcome();
    }
    draw();
  }

  function openFromHash() {
    const key = decodeURIComponent(location.hash.slice(1));
    const i = KEY_TO_INDEX.get(key);
    if (i != null && i !== state.runIndex) openRun(i);
  }

  function main() {
    fill(byId("help-close"), icon("close"));
    applyTheme(storageGet("volta-viz-theme"));
    byId("theme-toggle").addEventListener("click", () => {
      const order = [null, "light", "dark"];
      const current = document.documentElement.dataset.theme || null;
      const next = order[(order.indexOf(current) + 1) % order.length];
      storageSet("volta-viz-theme", next);
      applyTheme(next);
    });
    window
      .matchMedia("(prefers-color-scheme: dark)")
      .addEventListener("change", () => applyTheme(document.documentElement.dataset.theme || null));

    const filter = byId("test-filter");
    filter.addEventListener("input", () => {
      ui.filter = filter.value.trim();
      renderList();
    });
    filter.addEventListener("keydown", (ev) => {
      if (ev.key === "Escape") {
        filter.blur();
        return;
      }
      if (ev.key !== "ArrowDown" && ev.key !== "ArrowUp" && ev.key !== "Enter") return;
      ev.preventDefault();
      const order = ui.visibleOrder;
      if (!order.length) return;
      const at = order.indexOf(state.runIndex);
      const next =
        ev.key === "Enter"
          ? order[Math.max(0, at)]
          : order[Math.min(order.length - 1, Math.max(0, at + (ev.key === "ArrowDown" ? 1 : -1)))];
      location.hash = INDEX[next].key;
    });

    for (const b of document.querySelectorAll(".tab")) {
      b.addEventListener("click", () => setTab(b.dataset.tab));
    }

    byId("help-toggle").addEventListener("click", openHelp);
    byId("help-close").addEventListener("click", closeHelp);
    byId("help").addEventListener("click", (ev) => {
      if (ev.target === byId("help")) closeHelp();
    });

    document.addEventListener("keydown", (ev) => {
      if (!byId("help").hidden) {
        if (ev.key === "Escape" || ev.key === "?") {
          ev.preventDefault();
          closeHelp();
        }
        return;
      }
      const typing = /^(INPUT|TEXTAREA|SELECT)$/.test(document.activeElement.tagName);
      if (ev.key === "/" && !typing) {
        ev.preventDefault();
        filter.focus();
        filter.select();
        return;
      }
      if (typing || ev.metaKey || ev.ctrlKey || ev.altKey) return;
      if (ev.key === "?") {
        ev.preventDefault();
        openHelp();
        return;
      }
      if (ev.key === "[" || ev.key === "]") {
        ev.preventDefault();
        stepRun(ev.key === "]" ? 1 : -1);
        return;
      }
      if (!state.g) return;
      if (ev.key === "Escape") {
        state.focus = null;
        renderFocusBar();
        select(-1, { tab: false });
      } else if (ev.key === "f") fit();
      else if (ev.key === "+" || ev.key === "=") zoomBy(1.4);
      else if (ev.key === "-") zoomBy(1 / 1.4);
      else if (ev.key === "m") toggleMinimap();
      else if (ev.key === "n" || ev.key === "N") stepFocus(ev.key === "n" ? 1 : -1);
      else if (ev.key.startsWith("Arrow") && state.selected >= 0) {
        ev.preventDefault();
        walk(ev.key);
      }
    });

    installCanvas();
    renderStatusFilter();
    renderList();
    window.addEventListener("hashchange", openFromHash);
    if (KEY_TO_INDEX.has(decodeURIComponent(location.hash.slice(1)))) openFromHash();
    else renderWelcome();
  }

  main();
})();
