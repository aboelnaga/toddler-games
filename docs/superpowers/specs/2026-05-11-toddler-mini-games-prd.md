# Toddler Mini-Games — Product Requirements Document

**Date:** 2026-05-11
**Author:** Mohamed Aboelnaga
**Status:** Approved (pre-implementation)
**Companion document:** [2026-05-11-toddler-mini-games-design.md](./2026-05-11-toddler-mini-games-design.md) — technical spec answering *how*. This PRD answers *what* and *why*.

---

## 1. Vision

A small, beautiful collection of safe, gentle touch-based games for very young children — built first for the author's son, and built well enough to share with other families. The app feels like a quiet, warm corner of the digital world: nothing demands attention, nothing pressures the child, nothing collects data, nothing distracts a parent who is sitting beside them.

If a child opens the app, plays for five minutes, and the parent never has to intervene to dismiss an ad, defend a credit card, or worry about what was shown — the product has done its job.

## 2. Who it is for

### Primary user — the child

A real two-year-old. He cannot read. He taps things to see what happens. He drags his finger across screens. He laughs when something he touches reacts. He gets bored when nothing reacts within a few seconds. He has small hands and an unsteady grip. He sometimes tries to bite the device. He has no concept of "winning" or "losing" and gets frustrated when something is taken from him after he has earned it.

He is being raised speaking Egyptian Arabic at home, with English coming in from videos, books, and family.

What he needs from this app:
- To touch something and have it respond.
- To hear his home language acknowledged and used.
- To never feel scolded for doing the "wrong" thing.
- To explore without being rushed.

### Primary co-user — the parent

A parent who hands their toddler the tablet sometimes, and who would rather sit nearby than walk away. The parent might play *with* the child — pointing, naming animals, repeating sounds. Or they might keep half an eye on him while making dinner.

What the parent needs from this app:
- To trust that nothing inappropriate, advertising-driven, or data-harvesting is happening.
- To be able to step away for two minutes without finding their child watching an unrelated YouTube ad.
- To not have to read a privacy policy with a magnifying glass.
- To play together in either Arabic or English without juggling settings every session.
- To be able to disable specific games if today is a "no shape sorter, just bubbles" kind of day.

## 3. Core user stories

> As a parent, I want to open the app and hand the tablet to my child with no setup, every time.

> As a parent, I want to know — without reading fine print — that nothing my child does in this app is being recorded or sent anywhere.

> As a parent, I want to pick the spoken language and have it apply to every game and every voice prompt instantly.

> As a child, I want to tap something and have it respond with sound and movement.

> As a child, I want to drag things around without being told I did it wrong.

> As a child, I want to come back tomorrow and find the same toys waiting for me, exactly as I left them.

> As a parent, I want to access settings and the privacy policy without the gate being something my child can defeat by accident.

## 4. Game lineup

Each game is a self-contained "toy," not a level in a progression. There is no score, no win/lose, no streak, no unlockable content.

### 4.1 Tap-to-Discover Zoo
A scene full of friendly animals. Tap any animal — it moves, makes its sound, says its name in the active language, and a small label appears. That is the whole game. No goal, no end.

**What it teaches:** cause-and-effect; the link between animal, sound, and name in two languages.

### 4.2 Bubble Pop
Bubbles drift up from below at varied speeds and sizes. Tap one and it pops with a sound and a sparkle. New bubbles keep arriving. It never ends and you cannot lose.

**What it teaches:** hand-eye coordination; color awareness as a side effect.

### 4.3 Shape Sorter
Three shapes (star, circle, triangle) sit waiting. Three matching holes above them. Drag a shape — when it gets near its hole, it gently snaps in. Cheers and sparkles on success. Wrong placement → the shape softly returns to where it started; no scolding sound, no red X, no negative feedback.

**What it teaches:** shape recognition; fine motor control through dragging.

### 4.4 Finger Paint
A blank canvas and a strip of colors. Drag a finger anywhere to leave a trail of that color. A magic-brush option drops sparkles and tiny stars in the trail. A clear button (with a gentle two-second hold so the canvas does not vanish on an accidental tap) starts fresh.

**What it teaches:** creativity; motor control; comfort with the touch surface as a creative tool.

### 4.5 Drive the Vehicle
A road or train track curves across the screen. A vehicle sits at one end. Drag it — it follows the road regardless of how messy your drag is. Animals along the route wave as you pass. A honk button is in the corner because honking is satisfying.

**What it teaches:** tracing; spatial coordination; the surprising joy of cause-and-effect (the wave) being earned by movement.

## 5. Constraints — values, not rules

These are not "things the developer must comply with"; they are values the product chose, articulated as constraints so we honor them throughout.

### 5.1 No music
The app contains no instrumental music — no background tracks, no jingles, no melodic celebration chimes. This is a faith-rooted preference of the author and applies project-wide. Audio in the app is built from animal sounds, sound effects, nature ambience, and spoken voice including vocal-only celebrations.

### 5.2 Bilingual, Egyptian Arabic first
The app launches in Egyptian Arabic. English is available as a toggle. The dialect choice matters: Modern Standard Arabic (the formal written language) is *not* a toddler's L1, and using it as primary at age 2 would be developmentally backwards. Egyptian Arabic is the language the child hears at home, and it happens to be the most widely understood spoken Arabic across the region — so the app is at once the right developmental fit *and* the right pan-Arab product.

### 5.3 Fully offline
The app never makes a network call. It does not need an internet connection. It does not request the `INTERNET` permission on Android. Its iOS privacy manifest declares zero network activity. This is a *product value*: the app should be trustworthy on an airplane, in a rural area, with a kid who has just spilled juice on the modem.

### 5.4 Zero data collection
The app collects nothing. No analytics, no crash reports, no telemetry, no user identifiers, no usage statistics, no anything. Nothing is sent off-device because nothing is recorded on-device beyond simple settings (language, sound on/off, which games are enabled). The privacy policy is short enough to fit on a postcard, and it is honest.

### 5.5 No fail state
No game in this app tells a child they did something wrong. Mistakes simply do not register as mistakes — they are exploratory taps that nothing happens to, or drags that gently return to their start. A child should be able to mash the screen for ten straight minutes and never see a frown, a red X, or hear a discouraging sound.

### 5.6 No timer, no streak, no progression
No game has a clock. No game tracks how many bubbles you popped. There are no achievements, no badges, no levels, no daily goals. Each game is the same on day one as on day fifty. The child returns to the toy he left.

## 6. Success criteria

We will know this app is working if:

1. **The child returns to it voluntarily.** Not just once. Across days. He asks for it.
2. **The parent does not have to mediate.** No "wait, let me click that away first." No "no, that game is paid, sorry." No accidental in-app purchases.
3. **The privacy story is provably true.** When the parent inspects what the app sends, they see nothing.
4. **Apple Kids Category and Google Play Designed for Families approve it** on first or second submission.
5. **Friends with toddlers download it** when shown.

Notably missing from this list: usage statistics, daily-active-user counts, retention curves. We are not building a business; we are building a thing the child likes. If it succeeds at #1, the rest are bonuses.

## 7. Art and audio direction

### Art
The look is warm and storybook — soft watercolor skies and meadows, with chunky friendly characters that have oversized round heads and big eyes. The mascot is a fox; he lives in the home screen and gently greets the child. The art balances two things research said it must: be warm enough that a toddler emotionally bonds to it, and be high-contrast enough that the toddler can find the tap targets without searching.

References: Sago Mini, Hey Duggee.

### Audio
The audio palette is wide *despite* having no music. Animal sounds, soft nature loops (birds, wind, water), sound effects (pop, whoosh, sparkle, vroom), spoken voice in either language, and vocal celebrations (a friendly "yay!" or clap). There is space for the child to hear quiet — not every action overlaps a sound, and the ambience is meant to be calming.

## 8. Out of scope (v1)

The following are explicitly *not* in the first version. They are good ideas; they are simply not in v1.

- Memory match game, peek-a-boo game, counting game, sticker / dress-up game, music-instrument game (the last one is permanently out, not "v2").
- A hub-world home screen (a single illustrated meadow with tappable spots) — beautiful, expensive, deferred.
- Modern Standard Arabic voice layer — useful for older children learning to read; v2 candidate.
- Multiplayer or co-play features.
- Customizable mascot (kid picks the species or color).
- Parental dashboard or cloud-synced progress.
- In-app purchases.
- Sign-in, accounts, profiles.
- Push notifications.

## 9. Out of scope (permanent — never)

These will not be added in any version, regardless of market pressure or revenue ideas. Listing them here so a future contributor understands the values.

- Advertising of any kind, however "child-safe."
- Tracking, analytics, telemetry of any kind.
- Subscription paywalls or one-time IAPs to unlock games.
- Social features (sharing, leaderboards, communities).
- Music, in the sense of instrumental tracks or melodic backing.
- Any feature that requires a network connection to function.
- Any third-party SDK whose data practices we cannot fully audit.

## 10. Open product questions

- **Mascot identity beyond "a fox":** does he have a name? Does he speak? In the launch lineup he is a silent watcher who only appears as the home-screen icon and the return-home button. Worth revisiting if the child responds strongly to him.
- **Reward for sustained play:** the no-progression rule is intentional, but is there a quiet "the fox waves" moment after a long session? Open. Default for v1: no — keep it simple.
- **Voice talent direction:** human Egyptian recording vs ElevenLabs AI voice. Both are workable; final decision lives in implementation, not product, but the voice quality is a product-defining choice.
- **Tablet-specific layouts:** v1 targets phone and tablet at the same resolution-class. A genuine tablet UI is a v2 question if usage warrants it.

---

*End of PRD. The companion technical design spec describes how this product is built. Implementation proceeds via a series of small, independently shippable slices — see the slice roadmap in the implementation plans.*
