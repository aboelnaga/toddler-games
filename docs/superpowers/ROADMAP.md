# Roadmap & Status

**Last updated:** 2026-05-19 (Slice 1 complete)
**Purpose:** orientation for any session (human or agent) picking up this project. Read this first.

---

## What this project is

A bilingual (Egyptian Arabic primary + English) Flutter app of five touch-based mini-games for children aged 2+, published to Apple Kids Category and Google Play Designed for Families. Fully offline, zero data collection.

Full context in two companion docs (read these next):

- [Product Requirements](specs/2026-05-11-toddler-mini-games-prd.md) — *what* and *why*
- [Technical Design Spec](specs/2026-05-11-toddler-mini-games-design.md) — *how*

---

## Hard invariants (do not violate without explicit approval)

Each invariant is also captured in a memory file under `~/.claude/projects/-Users-mohamedaboelnaga-github-2--year-Kids-games/memory/`:

1. **No network calls anywhere.** No `INTERNET` permission on Android release. No third-party analytics, crash, or ad SDKs.
2. **No instrumental music.** Sound effects, voice, nature ambience, and vocal celebrations are fine.
3. **No fail states in any game.** Mistakes do not register.
4. **Bilingual Egyptian Arabic primary, English secondary.** Egyptian colloquial (مصري), not MSA.
5. **No in-game text the toddler is expected to read.** Parent-facing screens are text-allowed.

---

## Slice roadmap

We build the app as a series of small, independently shippable slices. Each slice produces a working artifact and gets its own implementation plan + execution.

| # | Slice | Plan | Status | Output |
|---|---|---|---|---|
| 0 | Project scaffold + tooling | [plan](plans/2026-05-11-slice-0-scaffold-and-tooling.md) | **Complete** (tag: `slice-0-complete`) | Empty app runs on iOS sim + Android emu, with Riverpod 3, go_router 17, lint stack, codegen, CI, lefthook, AI rules, compliance hardening |
| 1 | App shell | [plan](plans/2026-05-11-slice-1-app-shell.md) | **Complete** (tag: `slice-1-complete`) | Home icon grid (placeholder tiles) + parent gate + settings, end-to-end navigable; 56 tests (50 widget + 6 golden) |
| 2 | Game 4: Finger Paint | [plan](plans/2026-05-19-slice-2-finger-paint.md) | **Plan ready, execute next** | AudioService infra + CustomPainter canvas, color palette, magic rainbow brush, long-press-to-clear |
| 3 | Game 2: Bubble Pop | not yet written | **Skeleton pending** | Many moving sprites tap-to-pop |
| 4 | Game 3: Shape Sorter | not yet written | **Skeleton pending** | Drag-and-drop with forgiving snap |
| 5 | Game 4: Finger Paint | not yet written | **Skeleton pending** | CustomPainter canvas + magic-brush effects |
| 6 | Game 5: Drive the Vehicle | not yet written | **Skeleton pending** | Drag along curved path (hardest game) |
| 7 | Release hardening + store submission | not yet written | **Skeleton pending** | Real privacy policy URL, real launcher icon, screenshots in both locales, age questionnaires, TestFlight / Play internal track |

**Plan depth was decided to be "B"** (per brainstorm conversation): full plans for slices 0, 1, 2; lighter skeleton plans for 3–7. Slice 2 plan + Slices 3–7 skeletons are the next planning task.

---

## How to pick up (cold start)

1. **Read the PRD first**, then the design spec. Both live under `docs/superpowers/specs/`.
2. **Check `MEMORY.md`** (auto-loaded by Claude Code when you open the project) for the hard invariants and project conventions.
3. **Pick your next move**:
   - If you're starting work: execute the next un-shipped slice (**Slice 1** is next — Slice 0 is complete).
   - If you need to plan: write the next missing plan (Slice 2, then 3–7 skeletons).
4. **Reference docs for any decision**:
   - Stack and rationale → design spec §9, §10
   - Product values and out-of-scope → PRD §5, §8, §9
   - Compliance posture → design spec §6
5. **AI rules**: `CLAUDE.md` is at repo root with the canonical invariants (Slice 0 is complete).

---

## Execution model

Each slice plan is executable in two ways:

1. **Subagent-driven (recommended)** — dispatch a fresh subagent per task, review between tasks. Use the `superpowers:subagent-driven-development` skill.
2. **Inline execution** — run tasks in the current session with batch checkpoints. Use the `superpowers:executing-plans` skill.

Tasks within a plan are decomposed into 2–5 minute steps with explicit TDD where applicable, exact file paths, exact commands, and expected outputs. The plans are written to be executable cold by an engineer who hasn't seen the conversation.

---

## Decision log (what's locked in)

These were debated and approved during brainstorming (2026-05-10 → 2026-05-11):

- Target: publish to Apple Kids Category + Google Play Designed for Families (not just personal use).
- Tech: Flutter stable + Riverpod 3 + go_router 17. **No Flame in v1** — pure widgets. Door open per-game later.
- Art: hybrid storybook (saturated chunky characters on warm watercolor backdrops). Generated via Nano Banana (Gemini 2.5 Flash Image) with a style-bible workflow.
- Audio: no music; SFX + voice + ambience + vocal celebrations only.
- Languages: Egyptian Arabic primary, English secondary toggle. MSA punted to v2.
- App shell: 2×3 icon grid home + math parent gate + settings with language/sound/per-game/about.
- Compliance: zero data collection. No SDKs. No `INTERNET` permission. GitHub Pages for privacy policy.
- Bootstrap: `very_good_cli` for scaffold, then strip Bloc and adopt Riverpod.
- Lint: `very_good_analysis` + `custom_lint` + `riverpod_lint`.
- CI: GitHub Actions, macOS-only goldens, forbidden-SDK + INTERNET grep guards.
- Hooks: Lefthook for pre-commit/push.
- AI rules: `CLAUDE.md` canonical + `AGENTS.md` + `.cursorrules` symlinks.

---

## Open items / decisions deferred to implementation

- **Voice talent**: human Egyptian recording vs ElevenLabs AI. A/B before recording at scale (deferred to Slice 2).
- **Style-bible generation**: master fox + reference scenes via Nano Banana. Can run in parallel with Slice 0–1 execution; non-blocking for code work.
- **Apple Developer + Google Play accounts**: not yet purchased. Required before Slice 7.
- **Privacy policy + Terms URLs**: not yet hosted. Required before Slice 7.

---

## File layout (what lives where)

```
docs/superpowers/
  ROADMAP.md                                     ← you are here
  specs/
    2026-05-11-toddler-mini-games-prd.md         ← product POV
    2026-05-11-toddler-mini-games-design.md      ← technical POV
  plans/
    2026-05-11-slice-0-scaffold-and-tooling.md   ← Slice 0
    2026-05-11-slice-1-app-shell.md              ← Slice 1
    (Slice 2+ plans to come)

~/.claude/projects/-Users-mohamedaboelnaga-github-2--year-Kids-games/memory/
  MEMORY.md                                       ← index, auto-loaded
  audio_no_music.md
  art_style_hybrid.md
  bilingual_arabic_english.md
  compliance_zero_collect.md
  dev_tooling_stack.md
```

Slice 0 has landed. The repo now has:

```
CLAUDE.md                                         ← AI rules (canonical)
AGENTS.md  → CLAUDE.md                            ← Codex CLI convention
.cursorrules  → CLAUDE.md                         ← Cursor convention
lib/                                              ← Flutter code
test/                                             ← tests mirror lib/
assets/                                           ← bundled images + audio
art/style-bible/                                  ← source art (NOT bundled)
scripts/                                          ← CI safety guards
.github/workflows/                                ← CI definitions
lefthook.yml                                      ← git hooks
analysis_options.yaml                             ← lint config
pubspec.yaml                                      ← deps + asset registration
```

---

## Next action

If you (or any future agent) are picking up here cold and want to make progress:

- **Execute Slice 2** — Finger Paint plan is written and ready at `docs/superpowers/plans/2026-05-19-slice-2-finger-paint.md`. 16 tasks, ~4–6 hours.
- **Write Slices 3–7 skeleton plans** in parallel if time allows.

The brainstorming and planning loop is done unless requirements change. Implementation is the next phase.
