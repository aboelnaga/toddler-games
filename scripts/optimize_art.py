#!/usr/bin/env python3
"""Optimize art/style-bible/ masters into bundle-ready assets.

Usage:
  python3 scripts/optimize_art.py                # process all
  python3 scripts/optimize_art.py --asset animal_cow  # match by substring

Per sprite (cream background → transparent):
  1. Crop a 5% border off all sides (removes Gemini sparkle watermark).
  2. Chroma-key the cream #fff5e6 background to alpha=0 with a tolerance,
     plus a thin feather of partial alpha for soft edges.
  3. Tightly crop to non-transparent content + 4 px breathing room.
  4. Resize to 512×512 with aspect preserved on a transparent canvas.
  5. Save to assets/images/games/<game>/<name>.png.

Per scene (watercolor backdrop, no alpha key):
  1. Crop a 3% border off all sides (Gemini sparkle).
  2. Resize to 2048-px width, aspect preserved.
  3. Save to assets/images/games/<game>/<name>.png.

Requires: pip3 install Pillow
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

try:
    from PIL import Image  # type: ignore
except ImportError:
    sys.stderr.write(
        "Pillow is not installed. Run:\n"
        "  pip3 install Pillow\n"
    )
    sys.exit(1)

REPO = Path(__file__).resolve().parent.parent
STYLE_BIBLE = REPO / "art" / "style-bible"

# Sprites are sourced from `art/style-bible/transparent/` — backgrounds
# already removed (typically by remove.bg or Gemini-with-magenta-bg).
# Scenes are sourced directly from `art/style-bible/` since they don't
# need keying — the watercolor wash IS the intended look.
SPRITE_SRC = STYLE_BIBLE / "transparent"

# (source filename relative to its kind's source dir, bundle path, kind)
ASSETS: list[tuple[str, str, str]] = [
    # Zoo sprites
    ("animal_cow.png", "assets/images/games/zoo/animal_cow.png", "sprite"),
    ("animal_bird.png", "assets/images/games/zoo/animal_bird.png", "sprite"),
    ("animal_cat.png", "assets/images/games/zoo/animal_cat.png", "sprite"),
    ("animal_dog.png", "assets/images/games/zoo/animal_dog.png", "sprite"),
    ("animal_duck.png", "assets/images/games/zoo/animal_duck.png", "sprite"),
    ("animal_elephant.png", "assets/images/games/zoo/animal_elephant.png", "sprite"),
    ("animal_sheep.png", "assets/images/games/zoo/animal_sheep.png", "sprite"),
    # Zoo scene (watercolor, not chroma-keyed)
    ("scene_zoo.png", "assets/images/games/zoo/scene_zoo.png", "scene"),
    # (Slice 6 will add: vehicle-car, scene_drive)
]

SPRITE_SIZE = 512
SCENE_WIDTH = 2048
def crop_border(img: Image.Image, percent: float) -> Image.Image:
    w, h = img.size
    dx, dy = int(w * percent), int(h * percent)
    return img.crop((dx, dy, w - dx, h - dy))


def tight_crop(img: Image.Image, padding: int = 4) -> Image.Image:
    """Crop down to the bounding box of non-transparent pixels + padding."""
    bbox = img.getbbox()
    if not bbox:
        return img
    x0, y0, x1, y1 = bbox
    w, h = img.size
    x0 = max(0, x0 - padding)
    y0 = max(0, y0 - padding)
    x1 = min(w, x1 + padding)
    y1 = min(h, y1 + padding)
    return img.crop((x0, y0, x1, y1))


def fit_into_square(img: Image.Image, size: int) -> Image.Image:
    img.thumbnail((size, size), Image.LANCZOS)
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ox = (size - img.width) // 2
    oy = (size - img.height) // 2
    canvas.paste(img, (ox, oy), img)
    return canvas


MAGENTA = (255, 0, 255)
MAGENTA_THRESH = 60


def has_meaningful_alpha(img: Image.Image, sample_corners: int = 4) -> bool:
    """Return True if the corners are already transparent — i.e. the
    source already has its background removed (came from remove.bg, an
    older bundle, etc.).
    """
    if img.mode != "RGBA":
        return False
    w, h = img.size
    px = img.load()
    if px is None:
        return False
    samples = [px[0, 0], px[w - 1, 0], px[0, h - 1], px[w - 1, h - 1]]
    transparent = sum(1 for s in samples if s[3] < 128)
    return transparent >= sample_corners // 2


def magenta_to_alpha(img: Image.Image) -> Image.Image:
    """Chroma-key magenta #ff00ff to transparency. Used when a fresh
    Gemini sprite arrives with the magenta background specified by the
    updated master prompt — no flood-fill needed because magenta never
    appears in our art, so a simple per-pixel threshold is safe and
    won't bleed into character interiors.
    """
    img = img.convert("RGBA")
    px = img.load()
    if px is None:
        return img
    w, h = img.size
    mr, mg, mb = MAGENTA
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            d = abs(r - mr) + abs(g - mg) + abs(b - mb)
            if d < MAGENTA_THRESH:
                px[x, y] = (r, g, b, 0)
    return img


def process_sprite(src: Path, dst: Path) -> None:
    """Sprite pipeline. Sources can be in three states; the script
    auto-detects which and does the right thing:

    1. Pre-transparent (from remove.bg, or an already-bundled asset) →
       no keying needed, just tight-crop + resize.
    2. Magenta-backgrounded (fresh Gemini output following the updated
       master prompt) → chroma-key magenta then tight-crop + resize.
    3. Anything else → falls through to (2), assumed magenta. Cream
       backgrounds are no longer supported (deprecated workflow).
    """
    img = Image.open(src).convert("RGBA")
    if not has_meaningful_alpha(img):
        img = magenta_to_alpha(img)
    img = tight_crop(img)
    img = fit_into_square(img, SPRITE_SIZE)
    dst.parent.mkdir(parents=True, exist_ok=True)
    img.save(dst, "PNG", optimize=True)
    print(f"  sprite  {src.name:24} -> {dst.relative_to(REPO)}  {img.size}")


def process_scene(src: Path, dst: Path) -> None:
    img = Image.open(src).convert("RGB")
    img = crop_border(img, 0.03)
    new_w = SCENE_WIDTH
    new_h = int(round(img.height * (new_w / img.width)))
    img = img.resize((new_w, new_h), Image.LANCZOS)
    dst.parent.mkdir(parents=True, exist_ok=True)
    img.save(dst, "PNG", optimize=True)
    print(f"  scene   {src.name:24} -> {dst.relative_to(REPO)}  {img.size}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--asset", help="process only sources whose filename contains this string"
    )
    args = parser.parse_args()

    for src_name, bundle_path, kind in ASSETS:
        if args.asset and args.asset not in src_name:
            continue
        src_dir = SPRITE_SRC if kind == "sprite" else STYLE_BIBLE
        src = src_dir / src_name
        dst = REPO / bundle_path
        if not src.exists():
            print(f"  skip    {src_name:24} (master missing)", file=sys.stderr)
            continue
        if kind == "sprite":
            process_sprite(src, dst)
        else:
            process_scene(src, dst)


if __name__ == "__main__":
    main()
