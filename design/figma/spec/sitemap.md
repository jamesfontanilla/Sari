# Sitemap & Navigation

All screens live in `src/screens/`. Routing is in-memory: a `Route` object in `App.tsx` with an optional `id` param for detail screens, and no URL router.

## 1. Screen map

### Main tabs (bottom nav, 5 tabs)

| Tab | Label | Screen | Contents |
| --- | --- | --- | --- |
| 1 | Home | `Home` | Greeting, Sari's daily summary, sales and utang cards, Low Stock, quick actions |
| 2 | Talaan | `Transactions` | Chronological list grouped by day; filters Lahat / Benta / Utang / Bayad / Restock |
| 3 | Paninda | `Inventory` | Products with qty and status; filters Lahat / Low Stock / Kategorya; scan button |
| 4 | Utang | `Customers` | Utang book: total owed, aging colors, filters Lahat / May Utang / Bayad na |
| 5 | Sari | `Chat` | Conversation with Sari, suggestion chips, composer (type or mic) |

> The original mockup had 4 tabs (Home / Ledger / Inventory / Insights). The FMD sitemap (5 tabs) supersedes it.

The bottom nav is a **floating glass pill** (Home · Talaan · Paninda · Utang · Sari) spanning the full width. There is **no separate mic button**: Voice is opened from the Home **Sabihin** tile and from the Sari chat mic.

### Flow screens (no bottom nav)

| Screen | Entry points |
| --- | --- |
| `Welcome` (animated intro) | Every app launch. **Simulan** goes to Onboarding (first launch) or Home (returning user). |
| `Onboarding` (3 steps) | Welcome → Simulan; Settings → "Ipakita ulit ang tutorial" |
| `Voice` | Home "Sabihin" tile, the Chat mic (when the input is empty) |
| `Scan` (Shelf / Resibo modes) | Home "Kunan" / "Resibo" tiles, Paninda "I-scan" |
| `ProductDetail` | Tap a product in Paninda or Low Stock |
| `CustomerDetail` | Tap a customer in Utang |
| `Settings` | Gear icon on Home |
| `Capital` ("Puhunan at Kita") | Home "Paglago" card, Talaan chart button (top right) |

## 2. Navigation flow

```
Welcome intro (animation → freeze → Simulan) ─▶ Onboarding(1 Voice · 2 Camera · 3 Chat) ─▶ Home   (onboarded=true; later launches: intro → Simulan → Home)

Home ─ Sabihin ─▶ Voice ─ confirm ─▶ back to origin + toast
     ─ Kunan ───▶ Scan ── confirm ─▶ back to origin + toast
     ─ Tanungin / summary card ─▶ Sari (Chat)
     ─ Benta card ─▶ Transaksyon      ─ Utang card ─▶ Utang
     ─ Low Stock row ─▶ ProductDetail ─ Tingnan lahat ─▶ Paninda
     ─ ⚙ ─▶ Settings
Paninda ─ row ─▶ ProductDetail      Utang ─ row ─▶ CustomerDetail ─ Magbayad / Dagdag utang (inline form)
Chat ─ transaction-like message ─▶ inline confirm card ─▶ saves
```

- Back from a flow or detail screen returns to the screen that opened it.
- Home cards deep-link to their sections; any tab is at most 2 taps from any action.

## 3. Screen specs

### Welcome (animated intro)
- Plain **yellow hue background**, the same soft gradient as the tutorial pages (`#fff1c2` fading to cream). No landscape here. The **"Sari"** wordmark sits near the top (about 48px from the top edge, always visible).
- **Layout:** content is grouped in the upper part of the screen instead of being spread to the bottom: the "Sari" title near the top, the animation directly below it (about 58% of the screen height, max 470px), and the **Simulan** button below the animation with a comfortable gap (28px below the animation box), with free space left under it.
- **Sari animation:** the green-screen Gemini clip, keyed to transparent. Sari hops in, waves, winks, and sparkles, then settles hands-on-hips. Plays muted and inline (8.3s, the source clip from 0.2s to 8.5s), then **freezes on the final pose**.
- **Simulan (Start) button:** fades in **1.5 seconds** after the animation starts, so users can go straight in without waiting. It stays visible from then on.
- **After the freeze:** the speech bubble starts **cycling through messages**, looping forever: each fades in (0.7s), stays about **5.5 seconds**, fades out (0.7s), then the next fades in. There is no tagline line on this screen.
  1. "Hi, ako si Sari, gabay mo sa pagtitinda!"
  2. "Sabihin mo lang, ako na ang magsusulat."
  3. "Kunan mo ang paninda, ako na ang bibilang!"
  4. "Tanungin mo ako kung kumikita ka ngayon."
  5. "Gumagana ako kahit walang internet!"
  - Under `prefers-reduced-motion`, only message 1 is shown, with no cycling.
  - Messages are kept to about 2–3 lines so the bubble never overlaps Sari's cap.
- **Skipping:** tapping anywhere during the animation jumps to the frozen final pose and shows everything immediately. The button can also be pressed any time after 1.5s, even mid-animation.
- **Fallbacks:** under `prefers-reduced-motion`, or if the video can't play, show the still final pose with the button right away. A 10-second safety net freezes and shows the button even if playback stalls.
- **Simulan** goes to Onboarding (first launch) or Home (returning user).

### Onboarding (3 steps)
1. **Sabihin lang** (`listening`): "Magsalita ka lang, ako na ang magsusulat." Example: "Si Juan, utang 150 — sardinas at bigas".
2. **Kunan ang shelf** (`scanning`): "Itapat ang camera sa paninda o resibo. Ako na ang bibilang."
3. **Tanungin mo ako** (`insights`): "Kumikita ba ako? Sino may utang? Sagot ko agad." Includes a "Gumagana kahit walang internet" note.
- Progress dots, a **Laktawan** (skip) button, and **Susunod** (last step: **Tara na!**) leading to Home.

### Home
- **Hero** (compact, ~270px tall at 375px wide, like the Tarsi reference): the landscape art (`bg-welcome.webp`, positioned to show the palms and store), **faded about 55% with a cream wash over the whole image** (heavier at the top and bottom edges) so Sari and the text stand out, and fading into the cream page at the bottom.
  - **Top row:**
    - Left: a round glass **streak button** (🔥 icon with an orange count badge = consecutive days with at least one record). Tapping it toasts "N araw kang sunod-sunod na nagre-record! 🔥".
    - Right: a single round glass **gear button** (opens Settings). The bell and people shortcuts and the pill that held them were removed; Paninda and Utang are already in the bottom nav.
  - Date eyebrow, e.g. "HUWEBES, OKTUBRE 9" (uppercase, letter-spaced).
  - Greeting, e.g. "Magandang hapon, **Aling Maria**!" (Plus Jakarta Sans, regular with a bold name).
  - Sari (`idle` pose) at the bottom-left of the hero, overlapping a compact white **speech card** on the right titled "**Sari**" (orange) with one short sales line (e.g. "Kinita mo ngayon: **₱650** — mas mataas ng ₱70 kaysa kahapon! 💪"). The nudge is left out of the hero to keep it short; low stock shows in the list below. Tapping the card opens Chat.
- **Mabilis na Gawain:** a horizontal row of tiles: Sabihin (Voice), Kunan (Scan, shelf), Resibo (Scan, receipt), Tanungin (Chat), Utang (Customers).
- **Summary cards:** Benta Ngayon (with trend) and Utang Total. Borderless, 24px radius.
- **Low Stock** list (empty state: "Sapat ang lahat ng paninda mo!").

### Voice
- Mic stage (pulse plus sound bars). "Nakikinig si Sari..."
- Input options:
  - "Subukan sabihin:" sample chips (utang / benta / bayad).
  - A text field "O i-type ang sinabi mo…" with a send button.
  - The mic button plays the first sample as a stand-in for speech.
- States:
  - **listening**: as above.
  - **thinking** (~0.9s): `thinking` pose and dots.
  - **understood**: "Naintindihan ko:" card (type badge, customer, amount, items; for a payment, the remaining balance), with **Tapos na** (save) and **Ulitin**.
  - **confused**: `confused` pose, "Sorry, hindi ko na-gets yun. Puwede mo ulitin?", and **Ulitin**.
- Saving returns to the origin with a toast in Sari's voice.

### Scan
- Segmented control: **Shelf** / **Resibo**.
- **Shelf mode:**
  - Dark shelf camera, a sweep line, and the `scanning` hint.
  - Then the green detection boxes appear.
  - A sheet shows "Inventory Updated!" with +/− steppers per item and **Tapos na**.
- **Resibo mode:**
  - A paper receipt mock ("ABC Wholesale"), then OCR highlights.
  - A sheet shows "Nabasa ko ang resibo" with items, qty, unit cost and total, and **I-save ang restock**.

### Transaksyon
- **Layout (kept light, max three controls on screen):**
  1. **Top bar:** title "Talaan" and, on the right, one round glass **chart button** ("Puhunan at Kita") that opens the Capital screen. (The big "Puhunan at Kita" card was removed.)
  2. **View switch** (segmented control, 3 segments): **Kalendaryo** (month calendar for nightly revenue; **the default**, shown first and selected whenever the Talaan tab is opened) · **Log** (daily and weekly sales) · **Transaksyon** (the transaction list).
  3. **One context line under the switch:**
     - In **Transaksyon**: on the left "Benta ngayon ₱650 · 9 benta", on the right a small **filter pill** ("Lahat ▾") that opens a menu: Lahat, Benta, Utang, Bayad, Restock. (The row of five filter chips was replaced by this one pill.)
     - In **Log**: on the left the period summary ("Huling 30 araw: ₱5,200 · 52 benta"), on the right a tiny two-option toggle **Araw | Linggo**.
     - In **Kalendaryo**: nothing extra (the calendar has its own month header).
- **Kalendaryo** (revenue calendar): where the user types the **overall revenue of each day at night**.
  - Header: month name and year with ‹ › buttons (can go back in time, not past the current month).
  - A month grid, Linggo to Sabado (columns Li Lu Ma Mi Hu Bi Sa). Each day cell shows the day number and, under it, that day's revenue in a compact form ("650", "1.2k"). Orange and bold = typed by the user; soft grey-green = taken from recorded sales; empty = nothing. Today is outlined; future days are dim and cannot be tapped.
  - **Trend arrow:** every day that has revenue shows a tiny arrow in the top-right corner of its box: **green ▲** if that day's revenue is higher than the previous day's, **red ▼** if lower, nothing if equal. The first day with any revenue has no arrow (nothing to compare with), and days without revenue have none. The comparison uses the day's figure (typed if there is one, otherwise recorded sales), including across month boundaries.
  - Tapping a day opens an editor card under the grid: the date, an amount field "Kabuuang kita ng araw" (prefilled with the current figure), a hint "Naitalang benta: ₱650", and the buttons **I-save**, **Alisin** (only if a figure was typed) and **Isara**. Saving a blank field removes the typed figure.
  - Under the grid: "Kabuuan ngayong buwan: ₱X" and a legend (orange dot = ikaw ang naglagay; grey dot = mula sa naitalang benta; green ▲ / red ▼ = tumaas / bumaba kumpara kahapon).
  - There is no evening hint banner; the calendar stays clean. Today is simply outlined.
- **Araw-araw na log** (daily; Log › Araw): one row per day for the last 30 days, newest first.
  - Row: a date chip (month in caps, big day number), the day name ("Ngayon", "Kahapon", or the weekday), then "{n} benta · Pinaka-mabenta: {product} ×{qty}". On the right, the day's total sales in bold with "Tubo ₱X" under it.
  - Days with no sales are shown muted: "Walang benta".
  - Tapping a day expands it to show that day's sales (TransactionCards); tap again to collapse. Only one is open at a time.
  - Header above the list: "Huling 30 araw: ₱{total} · {n} benta".
- **Linggo-linggo na log** (weekly; Log › Linggo): one row per 7-day window for the last 8 weeks (same windows as the growth graph), newest first.
  - Row: a date-range chip ("Okt 3–9"), "{n} benta · Pinakamagandang araw: {weekday} ({₱})", the week's total on the right with "Tubo ₱X" under it, and a growth tag vs. the previous week ("+85%", green; red when negative).
  - Tapping a week expands it into its 7 days (day name, number of sales, total).
  - Header above the list: "Huling 8 linggo: ₱{total} · {n} benta".
- Day and week totals use each day's **revenue** (the figure typed in the Kalendaryo if there is one, otherwise the recorded sales). Rows for days with a typed figure show a small pencil mark.
- The transaction list shows what the filter pill selects.
- Grouped by "Ngayon", "Kahapon", then dates.
- **TransactionCard:** type icon (sale green, utang red, payment teal, restock amber), title, subtitle (items or customer), time, and signed amount. Outside the day-grouped Transaksyon list (e.g. detail histories) it also shows the day ("Kahapon", "Sep 17, 2026").
- Empty state uses the `empty` pose.

### Puhunan at Kita (Capital)
Top bar: back, "Puhunan at Kita". Sections, top to bottom:
1. **Kabuuan card:** three numbers: **Puhunan** (all capital in), **Benta** (all revenue), and a big **Kita = Benta − Puhunan** with a return percentage ("+136% balik") and a progress bar "Balik-puhunan" (revenue ÷ capital, capped at 100% fill). A loss shows in red ("Wala pang kita").
2. **Tubo sa nabenta:** a smaller card for the chosen period (tabs **Linggo** · **Buwan**): Benta in that period, **Tubo sa nabenta** (profit on the items actually sold, not counting unsold stock), and growth vs. the previous period of the same length. A note explains: "Hindi kasama ang paninda na hindi pa nabebenta."
3. **Paglago kada linggo:** the 8-week graph (see below).
4. **Puhunan:** a list of capital entries (date, note, amount, ✕ to remove) and an inline form **Magdagdag ng puhunan** (amount, note such as "Unang supply"). Restocks recorded by voice or receipt scan are also counted as capital and appear in the list as "Restock" rows (read-only).
5. **Kita kada gabi:** a plain link card (no icon) "Kalendaryo ng kita — Ilagay ang kita ng bawat araw" that opens Talaan › Kalendaryo. (The old manual-revenue form was replaced by the calendar.)

**Graph (WeeklyChart):** 8 bars, oldest to newest, one per 7-day window ending today. Bars are weekly **Benta** (orange); a green line with dots is the weekly **Tubo**. The newest bar is highlighted. Labels under the bars show the week's start date (e.g. "Okt 3"). A tag above the graph shows this week's growth vs. last week (e.g. "+85% ngayong linggo", red when negative). Empty weeks show a small stub.

### Home: Paglago card
Between the summary cards and Low Stock: a card titled **Paglago ng benta** with the growth tag ("+85% vs. nakaraang linggo"), and a mini 8-bar graph (no labels). Tapping opens the Capital screen.

### Paninda (Inventory)
- Chips: Lahat / Low Stock / Kategorya (grouped).
- Rows: art, name, qty and unit, status ring. Tap opens ProductDetail.
- **I-scan ang shelf** CTA.

### ProductDetail
- Large art, name, category, and a status pill.
- Editable fields:
  - Stock, with a −/+ stepper.
  - Low-stock threshold.
  - Sell price.
  - Buy price.
- Margin per unit and last restocked are shown.
- "Mga transaksyon" lists this product's history.

### Utang (Customers)
- Header line: "Kabuuang utang ₱1,250 · 5 suki" on the left and, on the right, a small orange **+ Magdagdag** pill ("Magdagdag ng umutang", i.e. add borrower).
- **Add-borrower form** (opens as a card at the top of the list when the pill is tapped; the pill is replaced by **Isara**):
  - **Pangalan** (required, e.g. "Mang Pepe").
  - **Utang ngayon** (optional ₱ amount). If filled, the borrower is created together with an utang record for that amount; if blank, only the borrower is added (balance ₱0, shown under "Bayad na").
  - Buttons **I-save** and **Kanselahin**. Saving is disabled until a name is typed. Enter in either field saves.
  - If the name already exists (ignoring capitals), the form shows "Nandiyan na si {name} sa listahan." and does not add a duplicate.
  - After saving, a toast reads "Naidagdag si {name}." (or "Naidagdag si {name} — utang ₱{amount}.") and the new borrower appears in the list.
- Chips: Lahat / May Utang / Bayad na.
- Rows: avatar with an aging dot, name, "Huling bayad: …" or "Wala pang bayad", and the balance. Sorted by balance, highest first.
-

### CustomerDetail
- Avatar, name, big balance, aging label ("3 weeks na walang bayad" in red), and lifetime credit.
- Buttons:
  - **Magbayad** opens an inline amount form (prefilled with the full balance) and saves an `utang_payment`.
  - **Dagdag utang** opens an inline amount form and saves an `utang_add`.
- A timeline of transactions.

### Sari (Chat)
- Persisted history, seeded with the mockup conversation. The list auto-scrolls so the newest message stays visible above the suggestions, composer and nav.
- Suggestion chips: "Kumikita ba ako ngayon?", "Anong pinaka-mabenta this week?", "Magkano utang lahat?", "Sino matagal na hindi nagbabayad?", "Ano kailangan i-restock?".
- Composer: mic button when empty (opens Voice), send button when there is text.
- Transaction-like messages get an inline confirm card. Unknown questions get the confused reply.

### Settings
- **Offline status:** the Airplane Mode visual toggle, "Gumagana pa rin kahit walang internet!", the checklist, the `offline` pose, and the "100% Offline" badge.
- **Data:**
  - "I-export ang data (JSON)" downloads a local file.
  - "I-reset ang demo data" asks for confirmation.
- **Tutorial:** "Ipakita ulit ang tutorial".
- **About:** version and "Walang login · Walang ads · Libre habambuhay".
- *Language preference: deferred (Tagalog/Taglish only per agents.md).*

## 4. Component map (`src/components/`)

| Component | Purpose |
| --- | --- |
| `Icon` | Stroke icon set |
| `Mascot` | Sari pose image (`pose`, `size`) |
| `ProductArt` | Product illustration by `kind` |
| `Avatar` | Customer face (+ optional aging dot) |
| `PillButton`, `Chip`, `TopBar`, `BottomNav`, `Fab`, `Toast` | UI primitives |
| `VoiceInputButton` | Mic circle with listening state (Voice screen) |
| `CameraCapture` | Shelf/receipt viewfinder with detection overlay (Scan screen) |
| `TransactionCard` | Type icon, title, subtitle, time, signed amount |
| `ProductCard` | Row: art, name, qty, status ring |
| `CustomerCard` | Row: avatar and aging dot, name, last payment, balance |
| `InsightBubble` | Sari's message bubble (chat and daily summary) |
| `DashboardSummaryCard` | Label, value, trend |
