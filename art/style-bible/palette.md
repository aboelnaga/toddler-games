# Project Palette

Source of truth: `lib/core/theme/design_tokens.dart` + `docs/superpowers/specs/2026-05-11-toddler-mini-games-design.md` §4.

Capped at ~6 colors per scene — pick the relevant ones and stay disciplined. If a new color is genuinely needed, add it here first and update `design_tokens.dart` together.

## Character colors

| Name | Hex | Where it goes |
|---|---|---|
| Fox orange | `#ff8c42` | Master fox primary fur; warm focal colour for any mammal hero. |
| Cream | `#fff5e6` | Fox belly + cheeks, page-background tone, neutral fills. |
| Blush pink | `#ff6b9d` | Cheeks, small accents, ribbon/bow style detail. Use sparingly. |

## Scene / background colors

| Name | Hex | Where it goes |
|---|---|---|
| Sky peach | `#ffe1c0` | Top half of soft watercolor gradients. |
| Meadow green | `#a8d895` | Bottom half of nature scenes, grass. |
| Text charcoal | `#2a2a2a` | Reserved for parent-facing text only. **Never** in kid art (no outlines). |
| Overlay dim | `rgba(0,0,0,0.4)` | Modal scrim. Not for character work. |

## Rules

1. **No outlines on characters.** Form comes from shape + value, not strokes.
2. **Saturated focal element on calm backdrop.** Hero pops in bold colour; backgrounds stay desaturated/watercolor-soft.
3. **One action on screen.** Don't compose busy scenes; toddler attention is single-target.
4. **Max ~6 hues per scene.** Pick from this palette, don't introduce ad-hoc tints.
5. **Catchlights matter.** Eyes always get a small white highlight — kindchenschema requirement.

## Forbidden

- Photorealistic textures.
- Black hard outlines on character bodies.
- Pastel-only execution with low contrast.
- Scary expressions / fangs / sharp teeth / wide-open mouths.
- Decorative text or labels in the art itself (UI handles text).
- Realistic anatomy (no proportional legs, slender necks, etc.).
