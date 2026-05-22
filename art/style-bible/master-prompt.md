# Master Prompt + Per-Asset Fragments

This is the canonical text to paste into Nano Banana (Gemini 2.5 Flash Image, via Google AI Studio).

**Generation order matters.** Generate the master fox FIRST. Every subsequent asset uses `mascot-fox.png` as an uploaded reference image so the style cross-pollinates.

---

## 0. Reusable style fragment

Paste this fragment at the **top** of every **sprite** prompt (master fox + every animal + the vehicle). Scenes/backdrops have a different style — see §6.

The background is now **pure flat magenta #ff00ff** (chroma-key green-screen style). Magenta never appears in our art palette, so post-processing strips the background trivially without risk of eating into character interiors. This replaces the old "flat cream #fff5e6" rule, which collided with the cream pixels inside characters (sheep wool, duck belly).

```
Illustration style: chunky kindchenschema cartoon character on a pure
flat magenta chroma-key background. The character has an oversized round
head, big round eyes with a small white catchlight in each eye, a tiny
rounded snout/nose, and a chunky compact body with short limbs — no
realistic anatomy. The character has NO outlines and NO black ink lines
anywhere on its body; form is built from clean flat shapes with gentle
inner shading. Reference exemplars: Sago Mini, Hey Duggee, Toca Boca.
Mood: warm, calm, friendly, safe for a 2-year-old. Square aspect ratio,
2048x2048, centered subject filling about 70% of the frame, generous
negative space around the character. No text, no decorative lettering,
no logos.

Background: a single pure flat magenta #ff00ff tone (chroma-key colour)
— NO watercolor, NO gradient, NO atmospheric wash, NO sky or meadow.
The character must appear isolated on flat magenta so the background
can be cleanly removed later. NO baked-in drop shadow beneath the
character (shadows will be added programmatically in the app).

AVOID: photorealism, fur texture detail, black outlines, harsh contrast,
realistic proportions, scary or sharp features, fangs, wide-open mouths,
predator stances, pastel-only low contrast, decorative text, watercolor
backdrops, gradient backgrounds, atmospheric washes, drop shadows under
the character, magenta anywhere ON the character (it is reserved for
the background only).
```

---

## 1. Master fox (mascot-fox.png) — GENERATE THIS FIRST

This is the single most important asset. Every later prompt cites the fox.

```
[paste the style fragment from §0 here]

Subject: A friendly fox cub, sitting upright facing the viewer, head
tilted very slightly to the right, eyes wide and smiling, tiny rounded
mouth in a soft closed-smile. Oversized round head, ear tips are short
and rounded (not pointy). Body is chunky and compact, two front paws
visible resting near the lap. Fluffy tail curled forward beside the body.

Colour:
- Primary fur: warm orange #ff8c42
- Belly, inner ears, snout, and cheek patches: cream #fff5e6
- Tiny blush dot on each cheek: blush pink #ff6b9d
- Eyes: deep brown #2a2a2a iris with a single small white catchlight
- Pupils slightly oversized for cuteness

Background: pure flat magenta #ff00ff (chroma-key colour), no
watercolor, no gradient, no shadow under the fox. The fox itself
contains NO magenta — magenta is reserved for the background only.
```

**Iteration tips:**
- If the fox has black outlines → re-prompt and re-emphasise "no outlines anywhere".
- If the proportions are realistic → re-emphasise "oversized round head, chunky compact body, no realistic anatomy".
- If you get harsh contrast or photo-realistic fur → re-emphasise "flat shapes with gentle inner shading, no texture detail".
- If the backdrop is too busy → ask for "pure watercolor wash, no details, no horizon line".
- If you want it slightly more on-brand: tell it to look at Sago Mini's mascot.

**Save:**
1. Download the chosen image as `art/style-bible/mascot-fox.png`.
2. From the same prompt, generate a couple of alternates if you want — keep them in `art/style-bible/alternates/` for future reference.
3. Do **not** copy this image to `assets/`. Optimized derivatives go there later.

---

## 2. Vehicle (Slice 6) — car

Prerequisite: `mascot-fox.png` exists. Upload it as a style-reference image.

```
[paste the style fragment from §0 here]

Style reference: match the kindchenschema cartoon style and palette of
the uploaded mascot-fox.png image.

Subject: A friendly cartoon car, side view, facing right. The car has an
oversized rounded body (taller than realistic, about 1.4 height-to-length
ratio), two big chunky black wheels with cream rims, a single large
rounded windshield with a small white catchlight on it (matches the fox's
eye highlight style), no driver visible, smiling round headlights.

Colour:
- Body: warm orange #ff8c42 (matches the fox)
- Wheels: deep charcoal #2a2a2a with cream #fff5e6 rims
- Windshield: pale sky peach #ffe1c0 with one small white catchlight
- A tiny blush pink #ff6b9d roof or detail accent

Backdrop: transparent / removed (we'll composite over the road in code).
If transparent isn't available, use pure cream #fff5e6 background.
```

Save to `art/style-bible/vehicle-car.png`. Derivative optimized PNG-with-alpha goes to `assets/images/games/drive_vehicle/car.png` once we wire Slice 6.

---

## 3. Side animals along the road (Slice 6) — 3 variants

Each is a separate generation. Run them sequentially, each time uploading both `mascot-fox.png` AND the previous generation as references — keeps the family resemblance.

### 3a. Cow

```
[paste the style fragment from §0 here]

Style reference: match the kindchenschema cartoon style and palette of
the uploaded mascot-fox.png image.

Subject: A friendly cartoon cow, three-quarter view facing right, smiling,
one front hoof raised in a small wave. Oversized round head, big round
eyes with white catchlights, tiny rounded muzzle with a small smile,
short rounded horns (not pointed).

Colour:
- Body: cream #fff5e6 with a few large soft blush pink #ff6b9d spots
- Hooves and horns: warm orange #ff8c42
- Inner ears, muzzle: cream #fff5e6
- Tiny blush dots on cheeks
- Eyes: deep brown with white catchlights

Backdrop: transparent / removed. Fallback: pure cream #fff5e6 background.
```

### 3b. Bird

```
[paste the style fragment from §0 here]

Style reference: match the kindchenschema cartoon style and palette of
the uploaded mascot-fox.png image.

Subject: A friendly cartoon songbird perched, three-quarter view facing
right, smiling, one wing slightly raised mid-wave. Oversized round head,
big round eyes with white catchlights, tiny rounded beak in a small
closed smile.

Colour:
- Body: blush pink #ff6b9d
- Belly accent and inner wings: cream #fff5e6
- Beak and feet: warm orange #ff8c42
- Eyes: deep brown with white catchlights

Backdrop: transparent / removed. Fallback: pure cream #fff5e6 background.
```

### 3c. Cat

```
[paste the style fragment from §0 here]

Style reference: match the kindchenschema cartoon style and palette of
the uploaded mascot-fox.png image.

Subject: A friendly cartoon cat sitting upright, three-quarter view
facing right, smiling, one front paw raised in a small wave. Oversized
round head, big round eyes with white catchlights, tiny rounded muzzle
with three tiny whisker dots and a small closed-smile mouth, rounded
non-pointy ears.

Colour:
- Body: warm orange #ff8c42 (slightly lighter than the fox so they read
  as different characters — push toward #ffb27a)
- Belly, inner ears, snout: cream #fff5e6
- Tiny blush dot on each cheek: blush pink #ff6b9d
- Eyes: deep brown with white catchlights

Backdrop: transparent / removed. Fallback: pure cream #fff5e6 background.
```

---

## 4. How to use these in the app

For each generated asset:

1. Save the **source** image (high resolution, exactly as Nano Banana produced it) under `art/style-bible/<name>.png`. **Not bundled into the app.**
2. Open the source in your editor (or use `cwebp` / `pngquant` on the command line). Export an optimized derivative:
   - For character sprites: PNG with alpha, target 512x512 or 1024x1024 depending on intended on-screen size.
   - For backgrounds: WebP, target the largest expected device width (e.g., 1170 for iPhone Pro).
3. Drop the derivative into the matching subdirectory of `assets/images/`:
   - `assets/images/games/drive_vehicle/car.png`
   - `assets/images/games/drive_vehicle/animal_cow.png`
   - `assets/images/games/drive_vehicle/animal_bird.png`
   - `assets/images/games/drive_vehicle/animal_cat.png`
4. Register it in `pubspec.yaml` under `flutter.assets` if a new directory.
5. Reference it in code via `Image.asset('assets/images/games/drive_vehicle/car.png')`.

---

## 5. Iteration discipline

- Generate, judge, regenerate. Don't accept the first output if a constraint slipped (especially: outlines, realistic anatomy).
- Compare every new asset side-by-side with `mascot-fox.png`. If it doesn't look like part of the same family, regenerate.
- Commit `art/style-bible/` changes in small focused commits (one asset per commit) so we can revert a single bad generation.
- Bundled `assets/` are only added once the source art is approved — there's no value in shipping a placeholder that will be replaced next week.
