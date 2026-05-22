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
    from PIL import Image, ImageDraw, ImageFilter  # type: ignore
except ImportError:
    sys.stderr.write(
        "Pillow is not installed. Run:\n"
        "  pip3 install Pillow\n"
    )
    sys.exit(1)

REPO = Path(__file__).resolve().parent.parent
STYLE_BIBLE = REPO / "art" / "style-bible"

# (source filename, bundle path, kind)
ASSETS: list[tuple[str, str, str]] = [
    # Zoo sprites
    ("animal_cow.png", "assets/images/games/zoo/animal_cow.png", "sprite"),
    ("animal_bird.png", "assets/images/games/zoo/animal_bird.png", "sprite"),
    ("animal_cat.png", "assets/images/games/zoo/animal_cat.png", "sprite"),
    ("animal_dog.png", "assets/images/games/zoo/animal_dog.png", "sprite"),
    ("animal_duck.png", "assets/images/games/zoo/animal_duck.png", "sprite"),
    ("animal_elephant.png", "assets/images/games/zoo/animal_elephant.png", "sprite"),
    ("animal_sheep.png", "assets/images/games/zoo/animal_sheep.png", "sprite"),
    # Zoo scene
    ("scene_zoo.png", "assets/images/games/zoo/scene_zoo.png", "scene"),
    # (Slice 6 will add: vehicle-car, scene_drive)
]

SPRITE_SIZE = 512
SCENE_WIDTH = 2048
# Floodfill threshold — distance between a candidate pixel and its
# flood-fill seed (corner pixel). Conservative so we never leak into
# character interiors (sheep wool, duck belly are dangerously close to
# the background cream). The dilation step below recovers any pixels
# we wrongly pulled in.
FLOOD_THRESH = 42

# Magenta marker — placed by floodfill into background regions so we can
# distinguish them. The character art never contains pure magenta.
MARKER = (255, 0, 255)

# Pixels to push the opaque mask outward after flood-fill. Recovers any
# character edge that the flood erroneously caught. Larger = safer but
# leaves more residual halo.
ALPHA_DILATE_PX = 2

# Edge feather radius in pixels — softens the alpha boundary so character
# silhouettes don't look hard-edged against the scene.
ALPHA_FEATHER = 1.2


def crop_border(img: Image.Image, percent: float) -> Image.Image:
    w, h = img.size
    dx, dy = int(w * percent), int(h * percent)
    return img.crop((dx, dy, w - dx, h - dy))


def background_to_alpha(img: Image.Image) -> Image.Image:
    """Remove the background by flood-filling from all four corners.

    The chroma-key approach (any cream-ish pixel → transparent) leaks at
    sprite-tile edges because of subtle compression and watercolor
    texture. Worse, it eats into character interiors that happen to be
    cream-coloured (sheep wool, duck belly).

    Flood-fill solves both: we seed from corners (definitely background)
    and only mark the *connected* cream region as transparent. Anything
    cream inside the character is unreachable and stays opaque.
    """
    img = img.convert("RGBA")
    w, h = img.size

    # Work on an RGB copy so floodfill can splash a marker colour without
    # interfering with the alpha channel.
    marker_img = img.convert("RGB").copy()
    for seed in ((0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)):
        ImageDraw.floodfill(
            marker_img,
            xy=seed,
            value=MARKER,
            thresh=FLOOD_THRESH,
        )

    marker_px = marker_img.load()
    img_px = img.load()
    if marker_px is None or img_px is None:
        return img

    for y in range(h):
        for x in range(w):
            if marker_px[x, y] == MARKER:
                r, g, b, _ = img_px[x, y]
                img_px[x, y] = (r, g, b, 0)

    # Dilate the opaque region a couple of pixels — this recovers any
    # character edge pixels that the conservative flood-fill happened to
    # catch (especially on light-cream silhouettes like the sheep's wool
    # or the duck's belly).
    a = img.getchannel("A")
    a = a.filter(ImageFilter.MaxFilter(size=2 * ALPHA_DILATE_PX + 1))

    # Then soft-feather so character edges don't read as hard-cut.
    a = a.filter(ImageFilter.GaussianBlur(ALPHA_FEATHER))
    img.putalpha(a)
    return img


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


def process_sprite(src: Path, dst: Path) -> None:
    img = Image.open(src)
    img = crop_border(img, 0.05)
    img = background_to_alpha(img)
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
        src = STYLE_BIBLE / src_name
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
