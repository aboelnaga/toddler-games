# Style Bible

Source-of-truth art references. **NOT bundled into the shipped app.**

## What lives here

- `mascot-fox.png`, `animal_*.png`, `vehicle-car.png`, `scene_*.png` — **the locked masters**. These are the raw Gemini outputs. They may still have a background (magenta for sprites following the new prompt, or cream for older sprites). NOT bundled directly.
- `transparent/` — sprites with backgrounds removed (via [remove.bg](https://www.remove.bg) for the original cream-bg generations, or via Gemini-with-magenta-bg + `optimize_art.py`'s automatic magenta keying for newer ones). This is the canonical source `scripts/optimize_art.py` reads sprites from.
- `master-prompt.md` — human-readable master prompt + per-asset fragments. **Sprites now request a flat magenta `#ff00ff` chroma-key background** so post-processing is trivial.
- `palette.md` — hex codes and usage rules (mirror of `lib/core/theme/design_tokens.dart`).
- `assets.json` — machine-readable manifest read by `scripts/art_gen.py`.
- `candidates/` — generated variants per asset (`<asset>/v1.png`...`vN.png`). Pick the winner, copy it up to `art/style-bible/<asset>.png`.

## Workflow

### Generate (automated)

```bash
# One-time setup
pip install google-genai
echo 'GEMINI_API_KEY=your-key-here' > .env   # gitignored

# Get a free key from https://aistudio.google.com → Get API key

# List available assets
python scripts/art_gen.py --list

# Generate 4 variants of one asset (default count)
python scripts/art_gen.py --asset vehicle-car

# Generate everything in assets.json
python scripts/art_gen.py --all
```

Variants land in `art/style-bible/candidates/<asset>/v1.png` ... `vN.png`.

### Lock the winner

1. Browse `candidates/<asset>/` and pick the best one.
2. Copy it up: `cp art/style-bible/candidates/vehicle-car/v3.png art/style-bible/vehicle-car.png`.
3. Optimize a bundled derivative:
   - For sprites: `cwebp -q 92 -resize 1024 1024 art/style-bible/vehicle-car.png -o assets/images/games/drive_vehicle/car.webp` (or keep PNG with alpha if transparency is needed).
4. Register new asset directories in `pubspec.yaml` under `flutter.assets`.
5. Commit `art/style-bible/<asset>.png` and `assets/images/games/<game>/<file>` together.

### Adding a new asset

Edit `art/style-bible/assets.json` — add an entry with:

```json
"my-new-asset": {
  "description": "short summary",
  "output_bundle_path": "assets/images/games/<game>/<file>.png",
  "prompt": "Subject: ...\n\nColour: ...\n\nBackdrop: ..."
}
```

Then `python scripts/art_gen.py --asset my-new-asset`.

## Why source art is NOT bundled

Style-bible images are 2048x2048 PNGs at 1–5 MB each. Bundling them inflates the app binary unnecessarily and risks pushing the APK past size thresholds that trigger store-review scrutiny. The bundled derivatives in `assets/` are the optimized versions; this folder keeps the originals for re-export.

## Style rules (don't deviate)

See `palette.md` for the full list, but the four that matter most:

1. **No outlines** anywhere on a character body. Form comes from flat shapes + soft inner shading.
2. **Kindchenschema proportions** — oversized round head, big eyes with catchlights, chunky compact body.
3. **One action on screen.** No busy compositions, no clutter.
4. **Max ~6 hues per scene** drawn from the palette in `palette.md`.

When in doubt, generate against `mascot-fox.png` as the style reference and judge whether the new asset looks like a sibling. If not, regenerate.
