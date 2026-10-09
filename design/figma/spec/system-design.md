# System Design

## 1. Architecture decision

**Chosen: Option A, PWA** (lowest demo risk). This repo is React 19 + Vite 8 + Tailwind v4 + TypeScript.

| Component | Option A: PWA (chosen) | Option B: Native Android |
| --- | --- | --- |
| Local LLM | WebLLM (Llama 3.2 1B/3B) or Transformers.js via WebGPU | llama.cpp via NDK, Llama 3.2 3B Q4_K_M |
| Speech | Whisper WASM | Whisper.cpp via NDK |
| Vision | ONNX Runtime Web + MobileNet/YOLOv8 | ONNX Runtime Mobile / TFLite |
| Storage | IndexedDB (Dexie) or SQLite WASM | SQLite (Room) |
| UI | React + Tailwind | Jetpack Compose |
| Offline | Manifest + Service Worker | Native |
| Cloud | Optional Firebase/Supabase sync (deferred) | Optional REST sync (deferred) |

**Decision tree:** if nobody on the team has shipped on-device ML on Android, use the PWA; if the polished demo matters more than raw speed, use the PWA. Otherwise native is an option.

## 2. Code layout

```
src/
  App.tsx              screen router (in-memory route stack), toast, wires store and screens
  nav.ts               Route / Nav types
  main.tsx             entry; registers the service worker in production
  index.css            design tokens and component styles
  data/
    types.ts           Product, Customer, Transaction, ChatMessage, AppState
    seed.ts            demo seed (timestamps relative to "now")
    selectors.ts       derived values: balances, aging, sales, profit, trend, top seller, low stock
    store.ts           useStore(): reducer + localStorage persistence
  services/
    parser.ts          ParserService: Tagalog/Taglish text → Intent (LLM stand-in)
    insights.ts        InsightEngine: question → answer, daily summary, aging
    format.ts          peso(), dates, relative day labels
  components/          Icon, Mascot, ProductArt, Avatar, UI primitives
  screens/             one file per screen
public/
  manifest.webmanifest, sw.js, icons/
```

## 3. Data model

### Implemented (TypeScript, `src/data/types.ts`)

```ts
Product     { id, name, kind, category, unit, qty, threshold, buyPrice, sellPrice, lastRestocked, aliases[] }
Customer    { id, name, nickname?, look, createdAt }
Transaction { id, type: "sale" | "restock" | "utang_add" | "utang_payment",
              amount, timestamp, customerId?, items: TransactionItem[], notes? }
TransactionItem { productId, qty, unitPrice }
ChatMessage { id, from: "user" | "sari", text, tip?, intent?, timestamp }
AppState    { version, products, customers, transactions, chat, onboarded,
              capital: CapitalEntry[], dailyRevenue: Record<string, number> }
CapitalEntry { id, amount, timestamp, note }
dailyRevenue: key = String(start-of-day timestamp), value = the overall revenue the user typed for that night
```

**Derived, never stored:**

- **Utang balance** = Σ `utang_add` − Σ `utang_payment` for a customer, floored at 0.
- **Last payment** is the latest `utang_payment` timestamp.
- **Aging** = days since the last payment, or since the first `utang_add` if they have never paid:
  - 🟢 under 7 days
  - 🟡 7–20 days
  - 🔴 21 days or more ("3 weeks na walang bayad")
- **Today's sales** = Σ `sale.amount` today. **Profit estimate** = Σ (unitPrice − buyPrice) × qty over today's sale items.
- **Trend** = today's sales vs. yesterday's, as a percentage.
- **Low stock** = `qty <= threshold`.
- **Puhunan (capital)** = Σ `capital[].amount` + Σ `restock` transaction amounts (receipt scans and voice restocks; shelf scans cost ₱0).
- **Revenue of a day** = `dailyRevenue[day]` if the user entered one (their overall figure replaces the recorded sales for that day, so nothing is double counted); otherwise Σ `sale` amounts recorded that day.
- **Benta (revenue)** = Σ revenue of every day that has recorded sales or a daily entry.
- **Kita (profit, kabuuan)** = Benta − Puhunan. **Balik** = Kita ÷ Puhunan (shown only when Puhunan > 0).
- **Tubo sa nabenta** (period) = Σ (unitPrice − buyPrice) × qty over sale items in the period. Always based on recorded items, even on days where the user entered an overall revenue.
- **Weekly buckets:** 8 windows of 7 days ending at the end of today; window 0 is the latest. Each has `sales` (revenue of each day in the window) and `profit` (Tubo sa nabenta).
- **Growth** = (this window − previous window) ÷ previous window, rounded; hidden when the previous window is 0.
- **Daily log** (`dailyLog`): for each of the last 30 days, `sales` = Σ sale amounts, `count` = number of sales, `profit` = profit on sale items, `top` = the product with the most units sold that day, and the day's sale transactions.
- **Weekly log** (`weeklyLog`): the same 8 windows as the weekly buckets, each with totals, `growth` vs. the previous window, the `bestDay` (highest sales), and its 7 `days`.
- Period tabs: Linggo = 7 days, Buwan = 30 days, each compared with the 7/30 days before it.

### Target ERD (from FMD, for the SQLite/IndexedDB migration)

| Entity | Fields | Prototype status |
| --- | --- | --- |
| Products | id, name, category, buy_price, sell_price, quantity, min_stock_threshold, image_url, last_restocked, created_at | ✅ (no image_url; uses illustration `kind`) |
| Transactions | id, type, amount, timestamp, notes, product_ids, customer_id | ✅ (product ids via items) |
| TransactionItems | id, transaction_id, product_id, quantity, unit_price | ✅ embedded in Transaction.items |
| Customers | id, name, nickname, utang_balance, last_payment_date, trust_score, created_at | ✅ balance/last payment derived; trust_score ⏳ |
| Insights | id, type (daily_summary/low_stock/utang_aging/profit_trend), content_json, generated_at | ⏳ computed live, not cached |
| CapitalEntry | id, amount, timestamp, note | ✅ new (Puhunan at Kita) |
| DailyRevenue | day → amount (typed each night in the Kalendaryo) | ✅ new |
| ConversationHistory | id, user_message, ai_response, intent_parsed, timestamp | ✅ as `chat` |

Relationships: Customer 1→N Transactions, Transaction 1→N Items, Product 1→N Items.

### Seed data (`seed.ts`, relative to "now")

- **Products** (sell/buy price, qty, threshold):

| Product | Sell | Buy | Qty | Threshold |
| --- | --- | --- | --- | --- |
| Sardinas | ₱25 | ₱20 | 1 | 3 |
| Bigas | ₱55 | ₱48 | 2 | 3 |
| Tansan | ₱15 | ₱11 | 3 | 3 |
| Noodles | ₱15 | ₱12 | 8 | 3 |
| Softdrinks | ₱20 | ₱16 | 10 | 3 |
| Kape | ₱10 | ₱7 | 5 | 3 |

- **Today:** 8 sales totaling **₱650**. Sardinas is the top seller with 8 pcs.
- **Yesterday:** sales of **₱580**, so the trend is +12%.
- **Earlier days:** sales back to **55 days ago** with a growing trend (about ₱40/day at the start, ₱155/day last week) so the weekly graph shows growth; days 2–13 are unchanged so the top-seller answers still hold.
- **Capital:** one entry, ₱2,500 "Unang supply", 56 days ago. The ₱288 noodles restock 3 days ago is also counted as capital.
- **Utang:**

| Customer | Balance | Activity | Aging |
| --- | --- | --- | --- |
| Juan | ₱450 | utang 6 and 4 days ago | 🟢 |
| Maria | ₱300 | utang ₱500, paid ₱200 eight days ago | 🟡 |
| Pedro | ₱200 | 11 days ago | 🟡 |
| Ana | ₱150 | 15 days ago | 🟡 |
| Lito | ₱150 | 22 days ago | 🔴 |

  Total **₱1,250**.

## 4. Services (internal interfaces)

No external APIs. Each service sits behind a function interface so a real model can replace the stand-in without UI changes.

| Interface | Target | Prototype implementation |
| --- | --- | --- |
| SpeechService | Whisper WASM | Simulated: sample-phrase chips and a text field feed the transcript |
| LLMService: `parseCommand(text, state) → Intent` | Llama 3.2 JSON extraction | `services/parser.ts`, rule-based |
| VisionService | ONNX MobileNet/YOLO + OCR | Fixed shelf detections and a fixed supplier receipt |
| DatabaseService | SQLite / IndexedDB | `data/store.ts` reducer + `localStorage` key `sari-state-v1` |
| InsightEngine: `answer(question, state)`, `dailySummary(state)` | LLM + DB context | `services/insights.ts`, rule-based over real state |

### Parser rules (`parser.ts`)

- Normalize: lowercase, strip punctuation except `₱`, map Tagalog number words (isa…sampu) to digits.
- **Intent keywords** (checked in this order):
  - `bayad` / `nagbayad` / `binayaran` → `utang_payment`
  - `utang` / `inutang` / `pautang` → `utang_add`
  - `restock` / `dumating` / `nag-restock` → `restock`
  - `benta` / `nabenta` / `nagbenta` / `bumili` / `binili` → `sale`
  - otherwise `unknown`
- **Customer:** a known customer name or nickname in the text, otherwise the word after `si` / `ni` / `kay` (skipping honorifics such as mang, aling, kuya, ate). For `utang_add`, an unknown name creates a new customer on save.
- **Products** match by aliases (e.g. sardines → Sardinas; coke → Softdrinks; tubig → Tansan).
- **Numbers:**
  - Followed by `pesos`/`piso`/`php`, or preceded by `₱`: the amount.
  - ≤ 50 and directly before a product alias: that product's quantity.
  - Any other number: the amount.
- **Amount fallback:** Σ qty × sellPrice. Products mentioned without a quantity default to qty 1.
- **Validation:**
  - A payment needs a known customer with a balance; it is capped at the balance, and the remaining balance is shown.
  - A sale needs at least one product.
  - Utang needs a customer and an amount.
  - Anything else is `unknown`, and the confused state appears.

### Mutations (store actions)

| Action | Effect |
| --- | --- |
| `commit(intent)` | Adds the transaction. Sale/utang decrease item qty (floored at 0); restock increases qty and updates buyPrice and lastRestocked; creates a new customer if needed. |
| `applyScan(items)` | Restock transaction (shelf count adds, amount ₱0) |
| `applyReceipt(items)` | Restock transaction with costs |
| `updateProduct(id, patch)` | Edit qty, threshold, or prices |
| `addChat(msgs)` | Appends to the conversation history |
| `addCustomer(name)` | Adds a borrower with no utang yet (the Utang tab's add-borrower form; with an amount it commits an `utang_add` instead, which creates the customer itself) |
| `addCapital(amount, note)` / `removeCapital(id)` | Manage capital entries |
| `setDayRevenue(dayStart, amount \| null)` | Set (or clear, with `null`) the overall revenue typed for a day |
| `completeOnboarding()`, `resetDemo()` | |

## 5. LLM prompt engineering (target)

- **System prompt:** Sari is a friendly Filipino business assistant; Tagalog first; JSON output for transactions and plain text for insights.
- **Extraction schema:**

  ```json
  { "type": "utang_add|utang_payment|sale|restock", "customer": "Juan", "amount": 150,
    "items": [{ "product": "sardinas", "qty": 1 }] }
  ```

- **Few-shot examples:** the Voice Bookkeeper commands in [prd.md](prd.md) §3.
- **Context:** the last 10 transactions, a compressed state block (top 5 products, utang summary), and today's date.
- **Templates:** transaction parsing, inventory matching, insight generation.

## 6. Model specifications (target)

| Model | Size | Quantization | Target speed |
| --- | --- | --- | --- |
| Llama 3.2 3B | ~1.8 GB | Q4_K_M | 10–15 tok/s mobile |
| Whisper Small | ~244 MB | FP16 | 1–2 s per 10 s of audio |
| MobileNet v3 | ~22 MB | INT8 | ~50 ms/frame |

## 7. Offline architecture

- **Implemented:**
  - `public/manifest.webmanifest` (installable, standalone, orange theme).
  - `public/sw.js`, registered only in production builds: it precaches the app shell on install, uses network-first for navigations with a cached fallback, and cache-first for same-origin assets.
  - The service worker also precaches the intro videos (`.webm`, `.mov`) and the final-frame image.
  - Fonts are self-hosted via `@fontsource`, so no Google Fonts request is made.
  - App data lives on the device in `localStorage`.
- **Target:** models bundled or downloaded on first launch and cached; SQLite/IndexedDB as the single source of truth; optional sync later.

### Local vs. internet disclosure

| Feature | Local | Needs internet |
| --- | --- | --- |
| Voice-to-text | ✅ (Whisper WASM, target) | Never |
| Product recognition | ✅ (ONNX, target) | Never |
| Transaction parsing | ✅ | Never |
| Insights | ✅ | Never |
| Data storage | ✅ | Never |
| First install / model download | — | Once |
| Cloud backup | — | Deferred, opt-in |
