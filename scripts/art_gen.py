#!/usr/bin/env python3
"""Batch-generate Toddler Games art assets via Gemini 2.5 Flash Image.

Usage:
  # List available assets:
  python scripts/art_gen.py --list

  # Generate 4 variants of a single asset:
  python scripts/art_gen.py --asset vehicle-car

  # Generate all assets defined in assets.json:
  python scripts/art_gen.py --all

Variants land in art/style-bible/candidates/<asset>/v1.png ... vN.png.
Pick the winner, copy it to art/style-bible/<asset>.png, then optimize a
bundled derivative into assets/images/<bundle_path>/.

Requires:
  pip install google-genai pillow python-dotenv
  echo 'GEMINI_API_KEY=...' > .env  (gitignored)

Get a free Gemini API key from https://aistudio.google.com.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
STYLE_BIBLE = REPO_ROOT / "art" / "style-bible"
MASTER_FOX = STYLE_BIBLE / "mascot-fox.png"
CANDIDATES = STYLE_BIBLE / "candidates"
ASSETS_JSON = STYLE_BIBLE / "assets.json"

# Style fragment is mirrored from art/style-bible/master-prompt.md §0. Keep
# the two in sync; this script reads from the constant for reliability.
STYLE_FRAGMENT = (
    "Illustration style: chunky kindchenschema cartoon character on a soft "
    "warm watercolor backdrop. The character has an oversized round head, "
    "big round eyes with a small white catchlight in each eye, a tiny "
    "rounded snout/nose, and a chunky compact body with short limbs — no "
    "realistic anatomy. The character has NO outlines and NO black ink "
    "lines anywhere on its body; form is built from clean flat shapes with "
    "gentle inner shading. The backdrop is loose airy watercolor in pastel "
    "tones, NOT detailed and NOT busy. Reference exemplars: Sago Mini, Hey "
    "Duggee, Toca Boca. Mood: warm, calm, friendly, safe for a 2-year-old. "
    "Square aspect ratio, 2048x2048, centered subject filling about 70% of "
    "the frame, generous negative space around the character. No text, no "
    "decorative lettering, no logos.\n\n"
    "AVOID: photorealism, fur texture detail, black outlines, harsh "
    "contrast, realistic proportions, scary or sharp features, fangs, "
    "wide-open mouths, predator stances, pastel-only low contrast, "
    "decorative text.\n\n"
    "Style reference: match the kindchenschema cartoon style and palette "
    "of the uploaded mascot-fox.png image so this asset reads as part of "
    "the same family.\n\n"
)

MODEL_NAME = "gemini-2.5-flash-image"


def load_dotenv() -> None:
    """Lightweight .env loader so we don't need python-dotenv as a hard dep."""
    env_file = REPO_ROOT / ".env"
    if not env_file.exists():
        return
    for line in env_file.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, v = line.split("=", 1)
        os.environ.setdefault(k.strip(), v.strip().strip('"').strip("'"))


def load_assets() -> dict:
    with ASSETS_JSON.open() as f:
        data = json.load(f)
    return {k: v for k, v in data.items() if not k.startswith("_")}


def import_gemini():
    try:
        from google import genai  # type: ignore
        from google.genai import types  # type: ignore
        return genai, types
    except ImportError:
        sys.stderr.write(
            "google-genai is not installed. Run:\n"
            "  pip install google-genai\n"
        )
        sys.exit(1)


def generate_asset(asset_name: str, count: int, client, types_mod) -> None:
    assets = load_assets()
    if asset_name not in assets:
        sys.stderr.write(f"Unknown asset: {asset_name}\n")
        sys.stderr.write(f"Available: {', '.join(assets.keys())}\n")
        sys.exit(1)
    if not MASTER_FOX.exists():
        sys.stderr.write(
            f"Master fox not found at {MASTER_FOX.relative_to(REPO_ROOT)}.\n"
            "Lock the master fox first (see art/style-bible/master-prompt.md §1).\n"
        )
        sys.exit(1)

    spec = assets[asset_name]
    prompt = STYLE_FRAGMENT + spec["prompt"]
    fox_bytes = MASTER_FOX.read_bytes()
    fox_part = types_mod.Part.from_bytes(data=fox_bytes, mime_type="image/png")

    out_dir = CANDIDATES / asset_name
    out_dir.mkdir(parents=True, exist_ok=True)

    print(f"Generating {count} variant(s) for {asset_name}...")
    for i in range(1, count + 1):
        try:
            response = client.models.generate_content(
                model=MODEL_NAME,
                contents=[prompt, fox_part],
            )
        except Exception as exc:  # noqa: BLE001
            sys.stderr.write(f"  v{i}: API call failed: {exc}\n")
            continue

        saved = False
        for candidate in response.candidates or []:
            for part in candidate.content.parts or []:
                inline = getattr(part, "inline_data", None)
                if inline is not None and inline.data:
                    out_path = out_dir / f"v{i}.png"
                    out_path.write_bytes(inline.data)
                    rel = out_path.relative_to(REPO_ROOT)
                    print(f"  v{i}: saved {rel}")
                    saved = True
                    break
            if saved:
                break
        if not saved:
            sys.stderr.write(f"  v{i}: no image bytes returned\n")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--asset", help="asset name from assets.json (e.g. vehicle-car)"
    )
    parser.add_argument(
        "--all", action="store_true", help="generate every asset in assets.json"
    )
    parser.add_argument(
        "--count",
        type=int,
        default=4,
        help="number of variants per asset (default 4)",
    )
    parser.add_argument(
        "--list", action="store_true", help="list available assets and exit"
    )
    args = parser.parse_args()

    if args.list:
        for name, spec in load_assets().items():
            print(f"  {name:18}  {spec.get('description', '')}")
        return

    if not args.asset and not args.all:
        parser.error("specify --asset NAME or --all")

    load_dotenv()
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        sys.stderr.write(
            "GEMINI_API_KEY is not set. Add it to .env (gitignored) or export it.\n"
        )
        sys.exit(1)

    genai, types_mod = import_gemini()
    client = genai.Client(api_key=api_key)

    if args.all:
        for name in load_assets().keys():
            generate_asset(name, args.count, client, types_mod)
    else:
        generate_asset(args.asset, args.count, client, types_mod)


if __name__ == "__main__":
    main()
