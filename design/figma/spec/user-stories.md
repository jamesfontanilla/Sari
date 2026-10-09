# User Stories & Acceptance Criteria

All stories are written from Aling Maria's point of view. Status: ✅ done in the prototype · 🟡 partly done (simulated AI) · ⏳ not yet.

## 1. Voice Bookkeeper

| ID | Story | Acceptance criteria | Status |
| --- | --- | --- | --- |
| VB-1 | I want to say "Si Mang Juan, utang 150, sardinas at bigas" and have it recorded, so I don't forget debts. | The transcript is parsed into customer, amount and items; a confirmation card shows them; on confirm, the utang balance goes up, the items are deducted from stock, and Sari confirms with "Okay, na-record ko na! …" | 🟡 parsing is real; speech is simulated |
| VB-2 | I want to say "Bayad ni Maria, 200 pesos" and have the debt reduced. | A payment is recorded, the balance goes down, and the remaining balance is shown. A payment above the balance is capped. | 🟡 |
| VB-3 | I want to say "Benta ko, 3 sardinas 45 pesos" and have the sale logged. | A sale is recorded, the stock goes down by 3, and today's sales total updates. If no amount is spoken, the price comes from the product's sell price. | 🟡 |
| VB-4 | When Sari doesn't understand, I want to be told kindly and allowed to retry. | The confused pose appears with "Sorry, hindi ko na-gets yun. Puwede mo ulitin?" and a retry action. | ✅ |
| VB-5 | I want to type the command if I can't speak (noisy store). | A text field on the Voice screen goes through the same parser. | ✅ |
| VB-6 | Transcription happens in under 2 seconds, offline. | Whisper WASM runs locally. | ⏳ |

## 2. Snap & Track

| ID | Story | Acceptance criteria | Status |
| --- | --- | --- | --- |
| ST-1 | I want to point my camera at my shelf and see what I have, so I don't count by hand. | Detected products appear with quantities; I can adjust them with +/−; on confirm, inventory updates. | 🟡 detections are simulated |
| ST-2 | I want an alert when a product runs low. | Products with qty ≤ threshold appear under Low Stock on Home and in Sari's daily summary, and get a Low Stock filter in Paninda. | ✅ |
| ST-3 | I want to snap a supplier receipt and have the costs recorded, so I know my buy prices. | Receipt mode shows the OCR'd items, quantities and costs; on confirm, a restock is saved, stock goes up, and buy prices update. | 🟡 receipt is simulated |
| ST-4 | Identification takes under 5 seconds, offline. | An ONNX model runs locally. | ⏳ |

## 3. Sari Insights

| ID | Story | Acceptance criteria | Status |
| --- | --- | --- | --- |
| SI-1 | I want to ask "Anong pinaka-mabenta ko this week?" in Tagalog. | Answers with the top product by quantity over the last 7 days, computed from stored sales. | ✅ |
| SI-2 | I want to ask "Magkano utang lahat?" | Answers with the total, the number of customers, the biggest debtor, and the oldest unpaid. | ✅ |
| SI-3 | I want a daily profit summary without asking. | Home shows Sari's daily summary: sales, estimated profit, change vs. yesterday, plus a low-stock or utang nudge. | ✅ |
| SI-4 | I want to see who hasn't paid in a long time. | The utang list shows an aging color (🟢/🟡/🔴). Asking "Sino matagal na hindi nagbabayad?" lists the 🔴/🟡 customers. | ✅ |
| SI-5 | I want to log a transaction from chat. | If a chat message parses as a transaction, Sari replies with a confirm card ("I-save" / "Huwag"). | ✅ |
| SI-6 | I want my data to stay on my phone. | No network calls for data; state lives in on-device storage; Settings can export a JSON backup locally. | ✅ |

## 3b. Puhunan at Kita (capital and profit)

| ID | Story | Acceptance criteria | Status |
| --- | --- | --- | --- |
| PK-1 | I want to enter my starting capital (my first supply). | The capital form saves an entry with amount, note and date; it appears in the list and in the Puhunan total. | ✅ |
| PK-2 | After a month, I want to add my revenue and see my profit. | Revenue is each day's typed figure if there is one, otherwise the recorded sales for that day; **Kita = Benta − Puhunan** is shown in pesos and as a percentage. | ✅ |
| PK-3 | I want to know my real profit on what I actually sold, not counting stock still on the shelf. | The **Tubo sa nabenta** card uses sale item prices and buy prices, for the last week or month, with growth vs. the period before. | ✅ |
| PK-4 | I want a graph of my weekly growth. | An 8-week bar graph of sales with a profit line, and a growth tag vs. last week; a mini version on Home. | ✅ |
| PK-5 | I want restocks to count as capital automatically. | Restocks from voice or receipt scans are included in Puhunan and listed as read-only rows. | ✅ |
| UT-1 | I want to add a new borrower myself. | The Utang tab has a **+ Magdagdag** button; the form takes a name and an optional starting utang; the borrower appears in the list; a duplicate name is refused. | ✅ |
| CAL-1 | By night, I want to type the overall revenue of my day on a calendar. | Talaan › Kalendaryo shows the month; tapping a day opens a field to type or edit that day's revenue; the figure appears on the day cell, in the Araw/Linggo logs, and in Puhunan at Kita totals and graph. | ✅ |
| CAL-2 | I do not want my revenue counted twice. | A typed figure replaces the recorded sales for that day only; days without one use the recorded sales. | ✅ |
| LG-1 | I want a daily log of my sales. | Talaan › Araw shows the last 30 days, each with number of sales, total, profit and best seller, and expands to that day's sales. | ✅ |
| LG-2 | I want a weekly log of my sales. | Talaan › Linggo shows the last 8 weeks with totals, profit, growth vs. the previous week and the best day, and expands to the 7 days. | ✅ |
| PK-6 | I want to fix a wrong entry. | Capital entries can be removed with ✕; a typed daily revenue can be removed with **Alisin** in the calendar. | ✅ |

## 4. General / non-functional

| ID | Story | Acceptance criteria | Status |
| --- | --- | --- | --- |
| NF-1 | It works without load or data. | It is installable as a PWA, the service worker caches the app shell, fonts are local, and there are no runtime network requests. | 🟡 built; precache verified by script; needs a real airplane-mode test on Chrome/Android |
| NF-2 | It speaks my language. | The UI and Sari's copy are in Tagalog/Taglish. | ✅ |
| NF-3 | It is free forever. | No login, ads, payments or telemetry. | ✅ |
| NF-4 | I can read it easily. | Compact Tarsi-like type scale (see `brands.md` §2), high contrast, bold headings, tap targets ≥ 44px. (The earlier 16px-minimum rule was replaced at the user's request.) | ✅ |
| NF-5 | My data survives closing the app. | State persists across reloads. | ✅ |
| NF-6 | First launch teaches me quickly. | Welcome, then a 3-step tutorial (voice, camera, chat) that is skippable, shown only once, and replayable from Settings. | ✅ |
