# fable — a poor man's Fable for Claude Code

![License: MIT](https://img.shields.io/badge/License-MIT-green.svg) ![Claude Code](https://img.shields.io/badge/Claude%20Code-skill-blue) ![PRs welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)

A single Claude Code slash command, `/fable`, that approximates Anthropic's top **Fable** model using **orchestrated Claude Opus** — for when Fable isn't available on your plan or is too expensive for you.

You type `/fable <your task>` and the message goes into "fake Fable mode": Opus, run at maximum effort, with diverse-method multi-agent panels, adversarial verification, and a self-critique pass.

## Honest expectations (read this first)

This does **not** make Opus as smart as Fable. No prompt, skill, or config can — Fable's edge is raw model intelligence, not a switch you can flip. There is no hidden "Fable mode".

What this **does** is spend more compute, intelligently, to close much of the practical gap:

- On **decomposable or checkable** work (refactors, reviews, research, multi-file changes) orchestrated Opus reaches Fable-level results, sometimes better, because you get breadth + independent verification.
- On a **single deep, tightly-coupled chain of reasoning** a residual gap remains: several Opus agents can make the same mistake, and a judge can't invent an insight none of them had. The skill shrinks that gap with method diversity, max thinking, and self-critique — and names the gap honestly instead of pretending.

If you want the real thing, use Fable. If you can't or won't, this gets you most of the way on most tasks.

## What you get

A `/fable` slash command that:

- runs on Opus at `effort: max`, explicit-invoke only (never auto-triggers)
- classifies your task and routes it automatically (or honors a route you name):
  - **trivial** → answers directly, no expensive panel
  - **hard single question** → a *judge panel*: several independent Opus solvers, each using a different method, + a judge that cross-checks and synthesizes
  - **review / research** → *find → adversarially verify → synthesize* over disjoint slices
  - **feature / fix** → *plan → implement → fresh adversarial reviewer* with real typecheck/test + red-team
- verifies before claiming done, matches your language, no filler

## Install

```bash
git clone https://github.com/michaelczesun/poor-mans-fable.git
cd poor-mans-fable
./install.sh            # copies skills/fable into ~/.claude/skills/fable
```

Or manually:

```bash
mkdir -p ~/.claude/skills/fable
cp skills/fable/SKILL.md ~/.claude/skills/fable/SKILL.md
```

Then **restart Claude Code** (a new skill folder is picked up on restart). Now type:

```
/fable <your task>
```

## Usage

```
/fable what's the root cause of the intermittent auth timeout?      # → judge panel
/fable security review of the payments module                        # → find-verify-synth
/fable add dark-mode support across the settings screens             # → plan-implement-verify
/fable as panel: which queue design fits a 10x traffic spike?        # → force a route
```

## What a run looks like

```text
> /fable what's the root cause of the intermittent auth timeouts?

[fable] hard single question → judge panel
  · spawning 4 independent solvers (first-principles · counterexample ·
    analogy-to-known-system · failure-mode-first)
  · self-critique pass on each
  · judge: cross-checking agreement vs dissent
→ Root cause: the token refresh races the request retry on cold start.
  3/4 solvers agree; 1 dissent (clock skew) flagged low-confidence.
  Fix + verification steps below.
```

Trivial questions skip the panel and get answered directly — you only pay for orchestration when the task is actually hard.

## Recommended companion setup (optional, but this is where it gets good)

`/fable` spends compute to approximate Fable. The cheapest compute is the compute you never spend. Pair it with a persistent knowledge base so Claude looks things up before re-deriving them:

- **[Obsidian](https://obsidian.md)** — free, local, plain-Markdown "second brain" / project vault. Keep architecture notes, decisions, solved bugs, and lessons as small linked notes. (Any Markdown notes folder works; Obsidian just makes the linking and graph pleasant.)
- **Wiki-first workflow** — in your `CLAUDE.md`, tell Claude to check the vault **before** expensive work, and to write anything expensive it figures out back into it. Next time the same question is near-free instead of another 6-agent panel.
- **Claude Code memory / `CLAUDE.md`** — project + global instructions, conventions, and a memory index that loads every session.

Why it matters: the fable clone is most cost-effective when it only orchestrates the genuinely new or hard parts. A good vault turns "research it again" into "read one note", so you reserve the expensive panels for what actually needs them. This repo doesn't bundle a vault — it just recommends the pattern, because it's what makes the whole thing economical.

## Cost & limitations

- A 5-solver + judge panel is ~6 model invocations — much more than a single call. Don't run trivial tasks through it; the skill routes those to a direct answer.
- `model: opus` and `effort: max` in the skill frontmatter assume you have Opus access. On a different plan, edit `skills/fable/SKILL.md` frontmatter (e.g. set `model: inherit` or remove `effort`).
- The orchestration uses parallel subagents. If your Claude Code build has a dedicated multi-agent workflow tool, the skill uses it; otherwise it falls back to spawning subagents — both work.

## Customizing

Everything lives in `skills/fable/SKILL.md`. Tune the solver count, the routing, the bug-class red-team list in the `plan-implement-verify` pattern, or the language/style rules to fit your projects.

## License

MIT — see [LICENSE](LICENSE).

Not affiliated with Anthropic. "Fable", "Opus", and "Claude" are Anthropic's. This is an independent workflow that orchestrates Claude Opus; it does not include or reproduce any Anthropic model.
