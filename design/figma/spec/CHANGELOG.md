# Changelog

New work goes under **Unreleased** first, written as part of updating the spec and before any code changes. Once it is implemented and verified, move it under a dated heading.

## Unreleased

_Nothing yet._

## 2026-10-10: Add borrower, calendar trend arrows

- **Calendar trend arrows** (per user): each calendar day with revenue shows a small green ▲ (higher than the day before) or red ▼ (lower) in the corner of its box; the legend explains them. Verified at 375px: green ▲ on Oct 8 (₱580 vs ₱155) and red ▼ on a day typed lower than the day before; equal days and the first day with revenue show no arrow.
- **Icon removed** from the "Kalendaryo ng kita" link card on Puhunan at Kita (per user).
- **Add borrower** (per user): the Utang tab gets a small **+ Magdagdag** pill beside the "Kabuuang utang" line. It opens a short form (name, optional starting utang) that adds a new borrower, optionally with an utang record; duplicate names are refused. New store action `addCustomer`. See `sitemap.md` (Utang), `system-design.md`, `user-stories.md` (UT-1). Verified at 375px: adding "Mang Pepe" with ₱150 (total ₱1,250 → ₱1,400, 6 suki, toast shown), a duplicate name refused, and a name-only borrower appearing under "Bayad na (1)".

## 2026-10-09: Evening hint removed

- **Evening hint removed** (per user): the "🌙 Gabi na! Ilagay ang kita ngayong araw." banner above the calendar is gone. Verified at 375px.

## 2026-10-09: Talaan simplified, calendar first

- **Calendar first** (per user: "when i click the talaan i want to see the calendar already"): opening the Talaan tab now shows the **Kalendaryo** straight away. The switch order is now **Kalendaryo · Log · Transaksyon** (the old "Talaan" segment is renamed **Transaksyon**). Verified at 375px: Talaan opens on the calendar, with the chart button, the 3-way switch and (in Log) the Araw | Linggo toggle.
- **Talaan simplified** (per user: "the buttons are overwhelming"): the Puhunan at Kita card is now a single round chart button in the top bar; the 4-way switch is now 3 segments (**Talaan · Log · Kalendaryo**) with Araw/Linggo as a tiny toggle inside Log; and the five filter chips became one compact filter pill ("Lahat ▾"). The screen goes from up to four stacked control rows to one switch plus one small line. See `sitemap.md` (Transaksyon).

## 2026-10-09: Daily and weekly sales log, Kalendaryo for nightly revenue

- **Kalendaryo for nightly revenue** (per user: "like a calendar, that by the night I will put there the overall revenue on that day"): a new **Kalendaryo** view in Talaan (switch is now **Lahat · Araw · Linggo · Kalendaryo**). A month grid shows each day's revenue; tapping a day lets the user type that day's overall revenue (edit or remove it too). A typed figure replaces the recorded sales for that day, so nothing is double counted; it feeds the Araw/Linggo logs and Puhunan at Kita (totals, graph). This **replaces** the "Dagdag na kita (manual)" section on Puhunan at Kita (`extraRevenue` is gone; new `dailyRevenue` map and `setDayRevenue`). The Puhunan screen now links to the calendar. See `sitemap.md` (Transaksyon › Kalendaryo), `system-design.md` §3, `user-stories.md` (CAL-1, CAL-2). Verified at 375px: the month grid, the evening "Gabi na!" hint, typing today's revenue (₱650 recorded → ₱720 typed; month total ₱2,315 → ₱2,385), the pencil mark in the Araw log, and Puhunan at Kita (Benta ₱6,590 → ₱6,660, Kita ₱3,872, +139%).
- **Daily and weekly sales log** (per user): the Talaan tab gets a view switch **Transaksyon · Araw · Linggo**. The Araw log lists the last 30 days (count, total, profit, best seller; tap to expand the day's sales). The Linggo log lists the last 8 weeks (totals, profit, growth vs. previous week, best day; tap to expand the days). New `dailyLog` / `weeklyLog` in `data/finance.ts`. See `sitemap.md` (Transaksyon), `system-design.md`, `user-stories.md` (LG-1, LG-2).

## 2026-10-09: Puhunan at Kita (capital, profit, weekly growth)

- **Puhunan at Kita (capital and profit) + weekly growth graph** (per user plan): a new `Capital` screen (not a tab, to keep 5 tabs) reached from a Home "Paglago ng benta" card and a Talaan row. Enter capital (first supply), revenue is auto-summed from recorded sales plus optional manual revenue, and it computes **Kita = Benta − Puhunan** with a return %, plus **Tubo sa nabenta** for the last week/month and an 8-week bar graph with a profit line and growth %. Restocks count as capital automatically. New data: `capital`, `extraRevenue`; new selectors in `data/finance.ts`; seed history extended to 55 days. See `sitemap.md`, `system-design.md` §3, `user-stories.md` §3b. Also: negative pesos now show as "−₱1,198" (was "₱-1,198"). Also added: Enter submits the capital forms; Sari answers questions with "puhunan", "paglago" or "balik" in them. Verified at 375px: Home card (+85%), the full screen (Puhunan ₱2,788, Benta ₱6,590, Kita ₱3,802, +136%), adding and removing capital and manual revenue, the loss state, and the chat answer.

## 2026-10-09: Home header pill removed

- **Home header pill removed** (per user): the glass pill with the bell and people icons is gone. The gear stays as one round glass button on the right so Settings (backup, reset, tutorial replay) remains reachable. Verified at 375px.

## 2026-10-09: Tarsi-scale typography

- **Tarsi-scale typography** (per user, from the Tarsi reference): all text is smaller and tighter, e.g. greeting 28→22px, section titles 20→15px, tile labels 14→11px, summary values 28→22px, row titles 17→14px, nav labels 12→10px. The earlier "16px minimum body" accessibility rule is superseded (`brands.md` §2). Implemented as one marked block in `index.css`. Verified at 375px on Home, Utang and Sari chat; Low Stock now fits on the first Home screen.

## 2026-10-09: Solid icons

- **Solid icons** (per user: "i dont want outline icons"): all feature and navigation icons are now filled instead of outlined, including the Home quick-action tiles (mic, camera, receipt, chat, ledger), the bottom nav, and the header controls. Simple glyphs such as chevrons and checks stay as lines; the Settings download and reset icons are solid too. See `brands.md` §3. Verified at 375px on Home, Voice and Settings.

## 2026-10-09: Slower speech bubble

- **Speech bubble cycles slower** (per user): each message now holds 5.5s (was 3.2s) and the fade in/out takes 0.7s (was ~0.45s). Measured in the page: shown at 0.1s, faded at 5.5s, next message at 6.3s, and so on.

## 2026-10-09: Welcome speech bubble cycling, bubble position, Home hero fade

- **Speech bubble moved down** another 16px (top 38px): it sits clearly below the "Sari" title and just above Sari's cap.
- **Home hero backdrop faded more** (per user, to highlight Sari): a uniform 55% cream wash now sits over the landscape (previously only the top and bottom edges were faded), plus a soft glow behind Sari.
- **Bubble position:** moved 16px lower (top 22px) so the wider cycling bubble no longer touches the "Sari" title.
- **Welcome speech bubble cycles:** after the intro freezes, the bubble rotates through 5 short messages (fade in, hold ~3.2s, fade out, repeat), starting with "Hi, ako si Sari, gabay mo sa pagtitinda!". Messages 2–5 are new copy written by Claude; editable in `Welcome.tsx` and `sitemap.md`.

## 2026-10-09: Welcome title nudged down

- **Welcome title nudged down:** the "Sari" wordmark moves down 16px (the animation and button stay where they are), for a little more breathing room at the top. Verified at 375px: it clears the speech bubble.

## 2026-10-09: Welcome button moved down more

- **Welcome button moved down more:** the **Simulan** button moves down another 40px (overlap -12px becomes a +28px gap below the animation box), leaving clear space under Sari's feet. Verified at 375px.

## 2026-10-09: Round mic button removed

- **Round mic button removed** from the bottom nav (per user). The glass nav pill now spans the full width. Voice remains available from the Home **Sabihin** tile and the Sari chat mic. Verified at 375px on Home.

## 2026-10-09: Welcome button nudged down

- **Welcome button nudged down:** the **Simulan** button moves down 18px (overlap with the animation box goes from 30px to 12px), so there is a little more room between Sari's feet and the button. Verified at 375px.

## 2026-10-09: Welcome layout moved up

- **Welcome layout moved up:** the animation and the **Simulan** button now sit higher, grouped right under the title (hero ≈ 58% of screen height, max 470px; button directly beneath) instead of the button being pinned to the bottom. The button overlaps the animation box by 30px to sit close under Sari. Verified at 375px.

## 2026-10-09: Welcome copy

- **Welcome tagline removed:** the line "Ang iyong AI tindera, nasa bulsa mo." no longer appears on the starting page (per user). The tagline still lives in the brand docs and the app manifest. Verified at 375px.
- **Welcome speech bubble copy:** changed from "Hi! Ako si Sari! Puwede mo akong kausapin o gamitin ang camera." to **"Hi, ako si Sari, gabay mo sa pagtitinda!"** (per user).

## 2026-10-09: Welcome intro timing and plain yellow background

- **Intro start at 0.2s:** the intro clip now starts at **0.2s** of the source (was 1.5s). The 1.5s cut was removing Sari's hop-in, so it now runs **8.3s** (0.2–8.5s) and the entrance is visible again (Sari rises at about 0.4s and jumps by 1.0s). Encoded 1.1 MB (WebM) and 1.4 MB (MOV).
- **Start button timing:** the **Simulan** button appears at **1.5s into playback** (was: after the freeze). The bubble and tagline still wait for the freeze. Verified: the button is shown at about 1.5s; the safety net freezes the intro at 12s (raised from 10s for the longer clip) and shows everything.
- **Welcome background:** removed the landscape on the starting page (per user). It now uses the same soft yellow gradient as Onboarding. The landscape stays on the Home hero. Also fixed a one-frame blank flash at the end of the intro by keeping the final-pose image under the video.

## 2026-10-09: Compact Home hero

- **Compact Home hero** (per user: header too tall vs. Tarsi): 48px glass controls, tighter spacing, a 26px greeting, a 120px Sari, and a one-line speech card (`shortSummary`). The hero goes from ~385px to 274px (measured at 375px). Low Stock is now visible on the first screen.

## 2026-10-09: Backdrop v2 (3D clay style)

- **Backdrop v2:** replaced `bg-welcome.webp` with the new 3D clay-style golden-hour street (same composition). It is used on Welcome and the Home hero. 853×1844, ~82 KB. Verified at 375px on both.

## 2026-10-09: App icon and intro timing

- **Intro timing:** the intro now starts at **1.5s** of the source clip (skipping the empty opening), so it runs 7s instead of 8.5s.
- **App icon:** the Canva "peeking Sari" logo (page 2) is now the favicon (browser tab), the PWA/home-screen icon (any, maskable, Apple touch), and a 1024px master for the future APK (`brands.md` §4b). Verified: the favicon is served, the tab title reads "Sari" (the dev server had to be restarted to pick up `site.json`), and the intro is 7s with Sari visible from the first frame. The service worker cache was bumped to `sari-shell-v4`.

## 2026-10-09: Tarsi-style UI refresh

- **Tarsi-style UI refresh** (per user reference screenshots of Tarsi): floating glass header controls, a date eyebrow with a bold-name greeting, a landscape hero with Sari and a speech card on Home, borderless soft-shadow surfaces with large radii, quick-action tiles, a floating glass bottom-nav pill plus a round mic button, Plus Jakarta Sans headings, and a streak badge. See `brands.md` §2–3 and `sitemap.md`. The Transaksyon tab is relabeled **Talaan** to fit the pill. The per-screen FAB is replaced by the round mic in the nav dock. Verified at 375px on Home, Utang and Sari chat.

## 2026-10-09: Intro animation v2 (green-screen Sari)

- **Intro animation v2:** replaced the yellow 4s splash with the new green-screen Gemini clip, keyed to transparent and played over the landscape on Welcome. It freezes on Sari's final pose, then the speech bubble, tagline and **Simulan** (Start) button appear. Welcome now shows on every launch (Simulan → Onboarding on first launch, Home after). The `Splash` screen and the `intro.mp4`/`intro-poster.webp` assets were removed. Verified at 375px in Chrome: the WebM plays with transparency, freezes, and the reveal works.

## 2026-10-09: Welcome background at full opacity

- **Welcome background:** removed the bottom cream wash entirely (per user: "lower the transparency of the backdrop"). The art is at full opacity; the tagline glow handles readability. Verified at 375px.

## 2026-10-09: Welcome background less washed out

- **Welcome background:** made less transparent, per user feedback. The bottom cream wash now starts at 72% (was 58%) and peaks at 0.5 opacity (was 0.88), so the landscape stays vivid; the tagline gets a soft glow instead. Verified at 375px.

## 2026-10-09: Splash logo animation

- **Splash intro:** the Gemini logo animation, trimmed to 4 seconds, muted and compressed (`intro.mp4` plus a poster), plays on every launch before Welcome or Home. It can be skipped, falls back to the poster under reduced motion, and is precached for offline use (service worker cache bumped to `sari-shell-v2`). The source clip was 10s / 2.2 MB; it now ships as 4.0s / 369 KB. Verified at 375px: it plays muted, then continues to Welcome.

## 2026-10-09: Welcome background art

- **Welcome background:** added the generated golden-hour barangay landscape as `src/assets/sari/bg-welcome.webp` (852×1846 WebP, ~120 KB). Welcome shows it behind the mascot, with a bottom cream wash for text contrast (`brands.md` §5). Verified at 375px.

## 2026-10-09: FMD integration, rename to "Sari", offline PWA

**FMD integration** (from the "Sari — Complete Foundational Matrix Documents" outline). Spec restructured into the 7 FMDs (`index`, `prd`, `system-design`, `user-stories`, `sitemap`, `agents`, `brands`); the old `README` and `01`–`04` files were folded into them. Implemented and verified at 375px in the dev app:

- **Data layer:** typed store with transactions (sale / restock / utang_add / utang_payment), products with prices, customers; persisted on-device; derived utang balance, aging, daily sales, profit, trend.
- **Voice Bookkeeper:** local Tagalog/Taglish parser for utang, payment, and sale commands; sample chips and a text field; confused state.
- **Snap & Track:** shelf mode with +/− adjustments, and a new receipt (OCR) mode that records a restock with buy prices.
- **Insights:** real answers computed from stored data (daily profit, top seller this week, total utang, aging, restock), chat actions with confirm cards, and Sari's daily summary on Home.
- **Navigation:** 5 tabs (Home, Transaksyon, Paninda, Utang, Sari) with a FAB; new Transactions, ProductDetail, CustomerDetail, Settings (export, reset, replay tutorial), and a 3-step Onboarding.
- **Offline / PWA:** manifest, service worker, self-hosted fonts.
- **Rename:** the project title is now **"Sari"** everywhere (UI wordmark, `<title>`, manifest). "Sari-Sari Business Brain" is retired.
- **Brand motion:** a 4-second logo entrance animation spec and Gemini prompt (`brands.md` §5, "Logo entrance animation").
- **Brand:** accessibility pass (16px body, 48px targets), teal accent, optional landing background art with a ChatGPT prompt (`brands.md` §5).
- **Code structure:** the 848-line `App.tsx` was split into `data/` (types, seed, selectors, store), `services/` (parser, insights, format), `components/`, and `screens/`.
- **Fixes found in testing:** names after honorifics ("Si Mang Pepe") were dropped; the newest chat message was hidden under the composer; detail histories showed the time without the date; the duplicate "Ang iyong AI tindera" eyebrow on Welcome was removed.
- **Verification:** walked through Welcome → tutorial → Home; voice payment (Maria ₱300 → ₱100); chat utang creating a new customer (Pepe); shelf and receipt scans updating stock; product edit; full payment (Lito → "Bayad na"); Settings. The production build makes no external requests. The service worker's precache discovery found and fetched all 115 build assets, but the in-app browser pane refuses to register service workers, so **a true airplane-mode test on Chrome/Android is still pending**.

## 2026-10-09: Spec folder created

- Added `spec/` (README, product, design system, screens, data model, changelog) documenting the current app.
- Adopted the spec-first workflow (see [README.md](README.md)) and referenced it from `AGENTS.md`.

## 2026-10-09: UI rebuilt to match the mockup, with Canva mascot

**Why:** Align the prototype with the 12-panel mockup and the official mascot assets.

- **Mascot:** replaced the hand-drawn SVG "Bren" with Canva PNG poses of **Sari** (`src/assets/sari/`). Renamed Bren to Sari in all copy.
- **Welcome:** new full-yellow onboarding with a speech bubble, waving mascot, and "Simulan" pill. The app now starts here.
- **Dashboard:** restyled summary cards, "Low" badges, product illustrations, larger colored quick-action circles. Nav renamed to Home / Ledger / Inventory / Insights. A save toast was added.
- **Voice:** single-screen flow (mic with sound bars, transcript, "Naintindihan ko" card, "Tapos na"), replacing the old three-step review/success flow. Saving updates Juan's utang.
- **Scan:** dark shelf camera view, green detection boxes, "Inventory Updated!" bottom sheet. Saving updates inventory counts.
- **Insights:** chat with Sari, seeded with the mockup conversation and tip card. The composer works, with keyword-based canned replies.
- **Ledger:** chips with counts (Lahat / May Utang / Nabayaran) that filter the list; illustrated avatars; sorted by balance.
- **Inventory:** chips (All Items / Low Stock / Categories) with status rings; "I-scan ang shelf" CTA.
- **Offline (new):** Settings screen behind the gear, with airplane toggle, offline checklist, and "100% Offline" badge.
- **State:** products and customers lifted into `App` so voice and scan actions update the dashboard, ledger, and inventory.
- **Data:** Lito's balance set to ₱150 (mockup shows ₱100) so the ledger totals ₱1,250. Inventory seed aligned with the dashboard's low-stock counts.
- **Fixes:** the `.camera` class collided between the quick action and the scan view (renamed the latter `.camera-view`); mascot sizing now overrides Tailwind's `img { height: auto }`.

## 2026-10-09: Ran locally

- Installed dependencies with pnpm and added `.claude/launch.json` (`pnpm dev` on port 8443).
