# User Stories & Acceptance Criteria — Sari

**Persona:** Aling Maria (45), Sari-Sari Store Owner in Barangay Poblacion.  
**Device Context:** Android device, offline / Airplane Mode, noisy store environment.

---

## 1. Feature 1: Voice Bookkeeper (Utang & Sales Ledger)

### US-1.1: Record Customer Utang via Tagalog Voice
> **As Aling Maria**, I want to press the microphone and say *"Si Mang Juan, utang 150 pesos, sardinas at bigas"* while handing goods across the counter,  
> **So that** customer debts are logged immediately without me hunting for a notebook and pen.
- **Acceptance Criteria:**
  1. The voice recording starts with a single tap on the prominent mic button.
  2. Transcription completes in under 2 seconds.
  3. The parser extracts: `customer: "Mang Juan"`, `type: "utang"`, `amount: 150.0`, `items: ["sardinas", "bigas"]`.
  4. If "Mang Juan" doesn't exist, a new customer record is automatically created; if he exists, his balance increases by ₱150.
  5. The assistant plays a verbal/audio confirmation: *"Na-record ko na! Si Mang Juan, utang ₱150."*
  6. The transaction appears at the top of the ledger.

### US-1.2: Record Cash Sales
> **As Aling Maria**, I want to say *"Benta ko tatlong Lucky Me pancit canton 45 pesos"*,  
> **So that** my daily sales total increments automatically.
- **Acceptance Criteria:**
  1. Identifies `type: "sale"`, `amount: 45.0`, `product: "Lucky Me pancit canton"`, `qty: 3`.
  2. Increments today's total sales by ₱45.
  3. Decrements inventory quantity of the matched product by 3.
  4. Displays a success confirmation toast/banner on screen.

### US-1.3: Record Utang Payment (Bayad)
> **As Aling Maria**, I want to say *"Nagbayad na si Aling Rosa ng 200 pesos"*,  
> **So that** her outstanding credit balance is immediately reduced.
- **Acceptance Criteria:**
  1. Identifies `type: "payment"`, `customer: "Aling Rosa"`, `amount: 200.0`.
  2. Reduces Aling Rosa's `utang_balance` by ₱200 in the database.
  3. Updates `last_payment_date` to current timestamp.
  4. Sari confirms: *"Salamat! Bawas na ang utang ni Aling Rosa ng ₱200."*

---

## 2. Feature 2: Snap & Track (Inventory Vision)

### US-2.1: Scan Shelf or Pile to Update Stock
> **As Aling Maria**, I want to point my camera at products on the counter or shelf and take a photo,  
> **So that** Sari detects the items and updates my stock count without manual entry.
- **Acceptance Criteria:**
  1. Tapping the camera button opens the viewfinder immediately.
  2. Detects common sari-sari items (e.g., canned sardines, instant noodles, soda bottles).
  3. Displays bounding boxes/tags with detected item names and counted quantities.
  4. Allows Aling Maria to tap "Kumpirma" (Confirm) with one touch to commit changes to SQLite.

### US-2.2: Low Stock Warning
> **As Aling Maria**, I want to see which items are below my restock threshold on my dashboard,  
> **So that** I know what to buy from the market tomorrow before I run out.
- **Acceptance Criteria:**
  1. Any item where `quantity <= reorder_threshold` is flagged with a high-contrast amber/red badge.
  2. A dedicated "Kulang sa Tindahan" (Low Stock) section appears on the home dashboard.

---

## 3. Feature 3: Sari Insights (Conversational AI Dashboard)

### US-3.1: Instant Profit & Sales Inquiry
> **As Aling Maria**, I want to ask *"Magkano kinita ko ngayon?"* or *"Kumikita ba ako?"*,  
> **So that** I know whether my store had a good day without calculating margins manually.
- **Acceptance Criteria:**
  1. The system computes today's Gross Sales, Total Cost of Goods Sold (COGS), and Estimated Gross Profit.
  2. Returns a friendly Tagalog summary: *"Magandang araw! May benta kang ₱540 ngayon, at tinatayang ₱120 ang kita mo. Patuloy lang!"*
  3. Responds in under 2 seconds.

### US-3.2: Debt Exposure (Sino may utang?)
> **As Aling Maria**, I want to ask *"Sino ang may pinakamalaking utang?"*,  
> **So that** I can politely follow up on collection before debts age out.
- **Acceptance Criteria:**
  1. Queries the customers table sorted by `utang_balance DESC`.
  2. Returns the top debtors with amounts in natural conversational Filipino.

---

## 4. Non-Functional & Demo Day Requirements

### US-4.1: Airplane Mode Verification
- All voice logging, image scanning, insight responses, and ledger reads/writes MUST work with Airplane Mode turned ON and WiFi turned OFF.
- Zero network socket requests initiated during core flows.

### US-4.2: Large Touch Targets & Senior Accessibility
- All primary buttons (Mic, Camera, Confirm) must have minimum touch areas of 56x56dp.
- Font sizes must be minimum 16sp for body text, 22sp for values/headers.
- High-contrast colors for outdoor sunlight readability.
