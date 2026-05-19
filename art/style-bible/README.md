# Style Bible

This folder holds source-of-truth art references for the project. **It is NOT bundled into the shipped app.**

## What lives here

- `mascot-fox.png` — the master reference image generated via Nano Banana (Gemini 2.5 Flash Image). Every subsequent generation references this image.
- `reference-scenes/` — scene-level references (zoo backdrop, road for vehicle game, etc.).
- `master-prompt.md` — the master prompt verbatim, plus prompt fragments for each asset type.
- `palette.md` — hex codes and usage rules.

## How to add a new asset

1. Open Google AI Studio (https://aistudio.google.com), Playground.
2. Select Gemini 2.5 Flash Image as the model.
3. Upload `mascot-fox.png` as a reference image.
4. Paste the relevant prompt fragment from `master-prompt.md`.
5. Generate. Iterate until happy.
6. Save the **source** to `art/style-bible/` (NOT to `assets/`).
7. Optimize a derivative (WebP, sized to target use) into `assets/images/games/<game>/`.

## Why source art is NOT bundled

Style-bible images are large, high-resolution masters. Bundling them inflates the app binary unnecessarily and risks pushing the APK past size thresholds that trigger store-review scrutiny.
