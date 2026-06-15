---
name: fable
description: A "poor man's Fable" for Claude Code. Approximate Anthropic's top Fable model using orchestrated Claude Opus when Fable is unavailable or too expensive. Runs the task at max effort with diverse-method multi-agent panels, adversarial verification, and a self-critique pass. Honest by design - this does NOT make Opus as smart as Fable. Invoke explicitly with /fable.
disable-model-invocation: true
user-invocable: true
argument-hint: <your task or question>
model: opus
effort: max
allowed-tools: Task Agent Bash Read Write Edit WebSearch WebFetch
---

## Task

$ARGUMENTS

## What this is (honest, read first)

- Fable 5 is Anthropic's top model tier, above Opus. Its edge is raw model intelligence, not a feature or a mode. No prompt, skill, or config can turn Opus into Fable. There is no hidden "Fable mode".
- If Fable is gated, unavailable, or too expensive for you, this is the next best thing: Opus pushed to its maximum. The goal is to get as close to Fable-grade output as Opus can, not to match it 100%. That gap is real and acknowledged.
- The lever is discipline + orchestration: spend more compute through DIVERSE solution paths (different methods, not the same reasoning repeated) plus adversarial verification plus a self-critique pass. On decomposable or checkable tasks this reaches Fable-level results. On a single deep, tightly-coupled chain of reasoning a residual gap remains (several Opus agents can make the same mistake) - shrink it with method diversity, max thinking, and self-critique. Never bail out to "just use Fable".

## Always

1. Restate the task in one line and classify its shape (A/B/C/D below).
2. If the project has a knowledge base (e.g. an Obsidian vault), docs, a README, or a memory store, check it FIRST. The answer may already be there, which saves an expensive panel. Write anything expensive you figure out back into it.
3. Route (below). When unsure between answering directly and running a panel, prefer the panel unless the task is clearly trivial.
4. Synthesize and answer. Relay panel results faithfully, do not just loosely summarize.
5. Verify before done: never claim "done / fixed / working" without proof in the same turn. Code: run typecheck / lint / tests / a real runtime check. Text or strategy: state your assumptions and do one self-critique round.
6. Match the user's language and writing style. No filler preamble, no echoing the question back, no false confidence.

## Routing by task shape

If the message itself names a route ("as panel", "review", "ship", "direct"), use it. Otherwise:

- D Trivial (lookup, one-liner, small known change): answer directly, NO panel (save tokens). Say it was trivial.
- A Hard single question (architecture decision, root cause, strategy, design direction): judge-panel.
- B Review / research / audit (coverage is the win): find-verify-synth.
- C Feature / fix / multi-file change: plan-implement-verify.

## Orchestration patterns (spawn subagents)

Default model for every subagent = the same Opus tier as this session. The real levers are fan-out breadth, GENUINE independence (no shared state between solvers), method diversity, and adversarial verification. Effort and thinking are inherited from the session. If your Claude Code build has a dedicated multi-agent workflow tool, use it; otherwise spawn parallel subagents with the Task/Agent tool.

A) judge-panel - the core Fable substitute
- Spawn 3 to 5 independent solver subagents. Each gets the FULL task in one turn, no shared state, a structured result (claim / reasoning / risks / confidence). For hard tasks give each solver a DIFFERENT explicit method or lens (first-principles, from-a-counterexample, analogy to a known system, failure-mode-first) so you get real diversity, not the same chain N times.
- Self-critique: each solver (or a separate agent) red-teams its own proposal for its biggest weakness before the judge runs.
- Then 1 judge subagent: cross-check agreement vs dissent, pick or synthesize the best answer, flag any claim only one solver made as low-confidence. Dissent marks the genuinely hard sub-point - look closer there, do not average it away.
- Hardest, non-decomposable reasoning: same structure, more solvers (5+), maximum method diversity, judge thinks deepest. Name the residual gap honestly instead of hiding it.

B) find-verify-synth
- Run over DISJOINT slices (per directory for code, per subtopic or source for research):
  FIND: "report EVERYTHING incl. low-confidence, with a confidence + severity tag; a later stage filters" (without this line the model silently drops findings).
  VERIFY (adversarial): separate agents try to REFUTE each finding (kills false positives); for research, also check that cited sources actually support the claim.
  SYNTHESIZE: dedupe, rank by verified severity, write the report.
- Optional: loop the FIND stage on productive slices until nothing new appears, cap ~3 rounds.

C) plan-implement-verify
- PLAN: 1 agent, full spec up front, written plan. High stakes: 2 planners + a judge.
- IMPLEMENT: execute the plan; parallel agents only on INDEPENDENT files (never shared state).
- ADVERSARIAL VERIFY: a FRESH reviewer that did NOT see the implementation reasoning runs the real typecheck / build / tests / runtime check (evidence, not claims) and red-teams the diff against common bug classes: state read after an early return, stale closure or caching, race conditions, off-by-one, null/undefined, unhandled errors, injection / unescaped input, plus the project's own known bug classes.
- LOOP: on failure, send the concrete errors back to IMPLEMENT, cap ~3 rounds.

## Cost (be aware)

These panels cost much more than a single call (5 solvers + judge ~ 6 model invocations). That is the price of approximating Fable without Fable. Never run trivial tasks through a panel (shape D = direct). Start with 3 solvers for medium-hard tasks, go to 5+ only when the stakes are high. A persistent knowledge base (see step 2) is the cheapest way to keep this affordable - it stops you re-orchestrating questions you already answered.
