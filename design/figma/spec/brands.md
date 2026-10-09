# Brand Identity & Design System

## 1. Brand identity

- **Name:** Sari. Short for "sari-sari" (Tagalog for "variety/sundry"). The project and UI title is just **"Sari"**. "Sari-Sari Business Brain" is the retired working title, so do not use it in the UI, the page title, or the manifest.
- **Naming pattern:** follows Filipino indie conventions: Tarsi, Clucky, Sari.
- **Personality:** Sari is your AI tindera: warm, helpful, slightly witty, like a trusted neighbor who is great with numbers.
- **Mascot:** a chick with an orange "S" cap and bandana. It replaces "Bren" with a "B" cap from the original PRD and mockup.
- **Positioning:** "Sari is the AI tindera that Tarsi would build if Bryl Lim made a sari-sari store app: offline, free, Filipino-first, with a personality you'd actually talk to."
  - vs. TingiFlow / Benta / Binta: they are POS systems; Sari is an assistant you talk to.
  - vs. Tarsi: Tarsi covers personal finance and Sari covers micro-business, so they are complementary.
  - vs. notebooks: Sari remembers everything, calculates, and advises.

### Traits

- **Warm, never cold:** speaks like a friend. "Uy, maganda benta mo today, ha!"
- **Helpful, never condescending:** Aling Maria is the boss and Sari is the assistant.
- **Slightly witty, never snarky:** gentle and encouraging. "Wala kang nakalimutang utang today! 🎉"
- **Filipino-first:** Tagalog/Taglish; English only for proper nouns and numbers.

### Voice & tone

| Situation | Sari says |
| --- | --- |
| Transaction logged | "Okay, na-record ko na! Si Mang Juan, utang 150 pesos — sardinas at bigas." |
| Daily summary | "Magandang gabi! Kinita mo ngayon: ₱485. Mas mataas ng ₱35 kaysa kahapon! 💪" |
| Low stock alert | "Heads up — 2 na lang sardinas mo. Pag-restock na siguro bukas?" |
| Utang reminder | "Si Aling Rosa, 3 weeks na walang bayad. Total utang: ₱450." |
| Error / confusion | "Sorry, hindi ko na-gets yun. Puwede mo ulitin?" |

Copy lives in `src/services/insights.ts` and the screens. Keep new copy in this voice.

## 2. Visual principles

- **Compact, Tarsi-like type (user decision, 2026-10-09):** text is small and tidy like the Tarsi reference, not large. This **replaces** the earlier "16px minimum body" rule. Readability is kept through high contrast, bold headings, and generous spacing; tap targets stay at least 44px.
- **High contrast** for bright outdoor and dim indoor use.
- **Minimal UI:** big buttons, voice first, no deep menus, at most 2 taps to any action.
- **Tap targets ≥ 48px.**
- **Color-blind safe:** status is never conveyed by color alone (icons and text accompany every color).
- **Budget Android:** works at 360×720; small bundle; no network at runtime.

### Palette

The FMD suggests warm yellow/amber, deep teal, and coral. The mockup and mascot are orange-led, so **orange stays primary** and teal is added for secondary info.

| Token | Value | Use |
| --- | --- | --- |
| `--orange` | `#f26b1d` | Primary actions, active states |
| `--orange-dark` | `#d9531a` | Headings and links on light backgrounds |
| `--orange-soft` | `#ffe9dc` | Halos, soft fills |
| `--yellow` | `#ffc83a` | Welcome, mascot |
| `--yellow-soft` | `#fff4d6` | Tip and transcript cards, product tiles |
| `--cream` | `#fffaf2` | App background |
| `--ink` / `--muted` | `#2b1d14` / `#6f6258` | Text (muted darkened for contrast) |
| `--border` | `#f0e6da` | Dividers |
| `--teal` / `--teal-soft` | `#0f766e` / `#d9f2ee` | Payments, informational badges |
| `--green` / `--green-soft` | `#2f9e57` / `#e3f5e9` | Sales, success, in stock |
| `--red` / `--red-soft` | `#d93a40` / `#ffe4e1` | Utang, low stock, overdue |
| `--blue` / `--purple` | `#2d8ad6` / `#8b5cf6` | Camera and Ask quick actions |

Transaction colors: sale green, utang red, payment teal, restock amber.

### Style direction: Tarsi-inspired (user reference, 2026-10-09)
- **No outlines on UI elements:** cards, rows, chips, tiles and buttons have no borders. Separation comes from soft shadows (`0 8px 24px rgba(60,40,20,.06)`) and the cream page background. The "Sari" wordmark has no text stroke. The Canva mascot art keeps its own outline.
- **Big curves:** cards 24px, tiles 20px, inputs 16px, buttons and nav fully rounded.
- **Glass controls:** header buttons and the bottom-nav pill are translucent white (`rgba(255,255,255,.78)`, `backdrop-filter: blur(16px)`) with a hairline white edge and a soft shadow.
- **Type:** large, heavy headings with tight tracking; a bold name in the greeting; an uppercase letter-spaced date eyebrow.

### Typography

- **Plus Jakarta Sans** (700/800) for headings, greetings and money values, **Inter** for body and UI text, and **Nunito** 900 only for the "Sari" wordmark. All are **self-hosted** via `@fontsource`, so the app works offline.
- **Type scale** (px, at a 375px-wide screen):

| Role | Size / weight |
| --- | --- |
| "Sari" welcome wordmark | 64 / 900 (Nunito) |
| Home greeting | 22 / 500, name bold 800 |
| Date eyebrow | 10.5 / 700, letter-spaced |
| Screen title (top bar) | 18 / 800 |
| Section title ("Mabilis na Gawain", "Low Stock") | 15 / 800 |
| Quick-action tile label | 11 / 600 |
| Summary label / value / note | 12 / 22 (800) / 11.5 |
| Row title / subtitle / amount | 14 / 12 / 14 |
| Badges, links, captions | 11–12 |
| Chips | 12.5 |
| Hero card "Sari" / text | 13 / 12.5 |
| Chat bubbles, tips, input | 14 / 13 / 14 |
| Buttons | 15 / 700 |
| Bottom-nav label | 10 / 600 |
| Onboarding title / text | 28 / 16 |

### Layout

The header lockup is the face mascot plus the wordmark "Sari" (Nunito 900, orange).

Mobile first, with the app shell capped at 430px and centered. At ≥600px viewports a tan backdrop and soft shadow frame it. Page padding is 16px. Bottom nav is 66px plus the safe-area inset (5 tabs). There is no floating action button; Voice is opened from the Home "Sabihin" tile or the chat mic.

## 3. Components and motion

Pill button (56px, orange), card (24px radius, no border), row, chip (soft fill, no border), quick-action tile (64px rounded square, orange line icon, label below), glass icon button (44px circle), glass bottom-nav pill (full width), status ring, toast, bottom sheet, chat bubbles, segmented control, stepper (−/+), and form field. Class names are in `src/index.css`.

- **Motion:** mic pulse, sound bars, thinking dots, scan sweep, sheet slide-up, and fade-down for toasts and messages. Everything is disabled under `prefers-reduced-motion`.
- **Icons: solid (filled).** Feature and navigation icons are filled glyphs in `currentColor`: home, list (Talaan), shopping bag (Paninda), ledger (Utang), chat (Sari), mic, camera, receipt, bell, people, settings gear, flame, bulb, alert, plane, send, play, download and refresh. Only the simplest UI glyphs stay as stroked lines (chevron, check, back, plus, minus, close). No outline-style icons for features. Product art and avatars are inline SVGs.

## 4. Mascot: Sari

Source: Canva "Sari-Sari" board (`DAHXg_0eqeU`), exported as transparent PNGs into `src/assets/sari/`. Use the `Mascot` component with a `pose`.

| Pose | Used on |
| --- | --- |
| `face` (head crop) | Header brand, chat avatar, "Naintindihan ko" card, summary card |
| `welcome` (waving) | Welcome |
| `idle` | Home greeting |
| `listening` | Onboarding step 1, Voice while listening |
| `thinking` | Voice while parsing |
| `success` | Onboarding finish, save confirmation sheet |
| `scanning` | Scan hint, onboarding step 2 |
| `insights` (lightbulb) | Daily summary card, onboarding step 3 |
| `empty` (with box) | Empty lists |
| `confused` | Voice "didn't understand", unknown chat question |
| `offline` | Settings offline card |

## 4b. App icon (logo)

Source: Canva board page 2: the white Sari chick peeking from the bottom-right of a rounded orange square (`#F26B1D`-ish). It is used for the **browser tab favicon**, the **PWA / home-screen icon**, and the future **Android APK launcher icon**.

| File (`public/icons/`) | Use |
| --- | --- |
| `sari-icon-1024.png` | Master (1024×1024, transparent rounded corners). Source for the APK and app stores. |
| `favicon-32.png`, `favicon-48.png`, `favicon.ico` | Browser tab |
| `icon-192.png`, `icon-512.png` | PWA manifest `any` icons (rounded square on transparent) |
| `icon-maskable-512.png` | PWA maskable: full-bleed (transparent corners filled: orange, with white at the bottom-right where the chick is). The chick meets the edges naturally; checked under a circle mask. |
| `apple-touch-icon.png` (180) | iOS home screen (full-bleed square; iOS rounds the corners) |

**APK (when packaged):** use `sari-icon-1024.png` as the Android adaptive icon foreground over an `#F26B1D` background (e.g. Capacitor/TWA icon generator). Keep the chick inside the central 66% safe zone. Not built yet.

## 5. Background art (landing page)

A landscape illustration sits behind the **Home hero only** (the Welcome screen uses the plain yellow hue like the tutorial). **Status: in use.** It is the golden-hour barangay street with a sari-sari store, in a soft **3D clay style** (v2, replacing the original flat painted version). It is generated from the prompt below and also used behind the Home hero. No overlay or wash: the art shows at full opacity. The tagline gets a soft light glow for readability. **File:** `src/assets/sari/bg-welcome.webp` (or `.png` / `.jpg`). If the file is absent the screen falls back to the yellow gradient, so the app never depends on it.

- **Format:** portrait, 9:19.5 (about 1080×2340), under 400 KB as WebP.
- **Composition:** open sky in the top 35% (the title sits there), a quiet middle where the mascot stands, and ground, shop or foliage at the bottom for depth. No text. No characters.
- **Mood:** warm golden-hour, friendly, flat/soft illustration, matching the mascot's outline and palette (orange `#f26b1d`, yellow `#ffc83a`, cream `#fffaf2`).

**Prompt to send to ChatGPT (image generation):**

> A vertical mobile app background illustration, 9:19.5 portrait. A warm, friendly Filipino barangay street at golden hour, in a soft hand-painted cartoon style with clean outlines, matching a cute chick mascot with an orange cap. A small sari-sari store with a colorful corrugated tin awning and shelves of snacks sits low on the left. Coconut palms, bougainvillea and a few nipa-hut rooftops frame the bottom. Gentle rolling green hills and a glowing yellow-orange sky with soft cream clouds fill the top third, which stays mostly empty so a title can sit there. The middle of the image is calm and open, with a simple dirt road and a few warm highlights. Palette: sunny yellow, warm orange, cream, soft green, a little teal. No text, no people, no animals, no logos, no UI. Flat-to-soft shading, high detail but uncluttered, wallpaper quality.

**Variants to try:**
- *Morning:* replace "golden hour" with "early morning light, pale yellow sky, light mist."
- *Rainy-day cozy:* "light rain, glowing store lights, warm puddle reflections."
- *Close-up store:* "close-up of a sari-sari store front, wooden counter, hanging sachets, no people."

Ask for 3 options and keep the one with the emptiest top third.

### Logo entrance animation (4 seconds)

**Status: replaced.** The first Gemini clip (yellow background, used as a 4s splash) is retired. The intro is now a **green-screen** Gemini clip (`gemini_generated_video_1f5bf40d.mp4`, 10s, 720×1280, key color `#0C9744`), played on the Welcome screen over a plain yellow background:
- Trimmed to **0.2–8.5s** (8.3s): it starts at 0.2s, just before Sari hops in (the first ~0.2s is empty green), and ends where Sari settles hands-on-hips. The audio is removed.
- Chroma-keyed to transparency and shipped as `src/assets/sari/intro-sari.webm` (VP9 with alpha, for Chrome/Android) and `intro-sari.mov` (HEVC with alpha, for Safari/iOS).
- `intro-sari-end.webp` is the transparent final frame. It is shown after the freeze and as the reduced-motion fallback.

The original 4-second timeline below is kept for reference:

| Time | Movement |
| --- | --- |
| 0.0–0.6s | Warm yellow background fades in; a soft cream glow pulses behind the center. |
| 0.6–1.4s | Sari hops up from just below the frame with a squash-and-stretch bounce (squash on takeoff, stretch mid-air), landing with a small settle. A tiny shadow ellipse grows as Sari lands. |
| 1.4–2.2s | Sari waves, with 2–3 wing flaps. A blink at 1.8s. Three small orange "excitement" ticks pop near the head. |
| 2.2–3.2s | The "Sari" wordmark springs in from the bottom, letter by letter (S-a-r-i), each letter overshooting slightly. |
| 3.2–4.0s | A small sparkle crosses the "S" on the cap, the tagline "Ang iyong AI tindera, nasa bulsa mo." fades up, and everything settles into a gentle idle breathing loop. |

**Prompt to send to Gemini (Veo / video generation):**

> Create a 4-second looping-friendly logo animation, 9:16 vertical, 1080×1920, flat 2D cartoon style with clean brown outlines and soft shading. Subject: a cute yellow chick mascot wearing an orange baseball cap with a white "S" and an orange bandana with an "S". Keep the character design exactly as in the reference image. Background: warm sunny yellow, soft radial cream glow in the center.
>
> Timeline:
> 0.0–0.6s: the yellow background fades in and the cream glow pulses gently.
> 0.6–1.4s: the chick hops up from below the bottom of the frame to the center with squash-and-stretch (squash before takeoff, stretch in the air), lands softly and settles; a small oval shadow on the ground grows as it lands.
> 1.4–2.2s: the chick waves its right wing twice with a happy open-beak smile, blinks once, and three small orange motion ticks pop beside its head.
> 2.2–3.2s: the word "Sari" in a bold rounded font (Nunito Black), orange with a dark brown outline, bounces in beneath the chick letter by letter, S-a-r-i, each letter overshooting slightly and settling.
> 3.2–4.0s: a small white sparkle glints across the "S" on the cap, the tagline "Ang iyong AI tindera, nasa bulsa mo." fades up in small dark-brown text, and the chick holds in a subtle idle breathing motion.
>
> Camera: locked off, no zoom. Motion: playful, bouncy, friendly, ease-out on landings. No other characters, no extra objects, no text other than "Sari" and the tagline. Smooth 30 fps. Final frame should be clean and usable as a static logo lockup.

**Tips:** attach `src/assets/sari/welcome.png` as the reference image. If Gemini adds unwanted text, add "Do not add any other text." Ask for a transparent or plain solid-color background if you want to place it over the landscape art.

## 6. ICP behavior model (Aling Maria)

- Uses Facebook Messenger daily (voice messages) and GCash.
- Comfortable with voice, not with typing long text.
- Reads Tagalog slowly; prefers visual and audio information.
- The phone is sometimes shared with family.
- Charges once a day (battery matters), buys ₱50–100 load (data is precious).

### Design implications

- Voice is primary; the keyboard is the fallback.
- Minimal notifications (battery).
- Small app size (limited storage).
- Zero data usage for core features.
- Onboarding is 3 screens max, with a voice demo.

## 7. Inspiration

- **Tarsi:** clean finance UI with a cute mascot; fast, simple, no friction.
- **Clucky (tryclucky.com):** the character *is* the product; "No ads. No data games."
- **Shared DNA:** privacy first, personality driven, natural input to instant action, buy-once or free.
