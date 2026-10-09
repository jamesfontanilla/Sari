# Sitemap, Screen Map & Navigation — Sari

**App Name:** Sari  
**Design Philosophy:** "Maximum 2 taps to any action. Big buttons. Voice-first."

---

## 1. Screen Hierarchy & Navigation Flow

```
[Splash / Initialization] (Checks local SQLite & models)
       │
       ▼
[Main Bottom Navigation Shell]
 ├── 🏠 Screen 1: Dashboard (Bahay)
 │    ├── Daily Sales & Est. Profit Card
 │    ├── Quick Utang Summary Card
 │    ├── Low Stock Alert Carousel
 │    └── Floating Action Bar: [🎙️ Boses] [📸 Kamera]
 │
 ├── 📖 Screen 2: Utang Ledger (Listahan ng Utang)
 │    ├── Customer List (sorted by highest balance)
 │    ├── Customer Detail Modal / Screen (history + payment button)
 │    └── Add Utang manually button
 │
 ├── 📦 Screen 3: Inventory (Paninda)
 │    ├── Product grid/list with real-time stock counts
 │    ├── Low stock badge filters
 │    ├── Edit product modal
 │    └── Quick Stock In / Camera Scan
 │
 ├── 💬 Screen 4: Sari AI Chat (Tanong kay Sari)
 │    ├── Natural conversation interface in Tagalog
 │    ├── Quick prompt chips ("Kumikita ba ako?", "Sino may utang?", "Anong paubos na?")
 │    └── Voice question input
 │
 └── ⚙️ Screen 5: Settings / About (Tungkol)
      ├── Local Storage Status
      ├── Airplane Mode & Offline Status indicator
      └── Reset / Seed Demo Data (crucial for demo testing!)
```

---

## 2. Screen Specifications

### 2.1 Screen 1: Home Dashboard (`DashboardScreen`)
- **Top Bar:** App Brand ("Sari 🏪"), Battery/Offline badge ("100% Offline").
- **Metric Highlights:**
  - *Benta Ngayong Araw* (Today's Sales): ₱XXX.XX
  - *Tinatayang Kita* (Estimated Profit): ₱XX.XX
  - *Kabuuang Utang* (Total Receivable): ₱X,XXX.XX
- **Quick Action Bar (Persistent at bottom or FAB):**
  - **Large Microphone Button (Orange/Gold, 72dp diameter):** Tap and speak immediately.
  - **Large Camera Button (Teal/Neutral, 56dp diameter):** Snap shelf or item.
- **Low Stock Banner:** Shows items with `<= reorder_threshold` quantity.

### 2.2 Screen 2: Utang Ledger (`UtangLedgerScreen`)
- **Header:** Total uncollected credit.
- **Customer Cards:**
  - Name / Nickname (e.g., *Mang Juan*, *Aling Rosa*).
  - Outstanding balance in bold pesos (e.g., **₱450.00**).
  - Last payment note.
  - Tap card -> Opens quick options: *Magbayad (Pay)* or *Dagdag Utang (Add)*.

### 2.3 Screen 3: Inventory Screen (`InventoryScreen`)
- **Search bar:** Instant filter by Tagalog product name.
- **Product List Items:**
  - Product Name (e.g., *Mega Sardines Red 155g*).
  - Stock remaining with status indicator (Green = Safe, Red = Paubos na).
  - Selling price (e.g., *₱24.00*).
  - Quick `+` and `-` buttons for one-touch manual adjustment.

### 2.4 Screen 4: AI Insights Chat (`SariChatScreen`)
- **Chat Bubble stream:** Warm personality responses in Tagalog/Taglish.
- **Pre-populated Question Chips (One-tap inquiry):**
  - *"Kumikita ba ako ngayon?"*
  - *"Sino may pinakamalaking utang?"*
  - *"Anong kailangan kong bilhin bukas?"*
- **Input field:** Voice recording button or text keyboard.

---

## 3. UI Component Map

| Component Name | Responsibilities | Target Specs |
|---|---|---|
| `BigVoiceButton` | Handles recording state, pulsating ring animation, trigger STT | Circular, 64–72dp, high contrast #E65100 |
| `MetricCard` | Displays numerical financial data with clear Tagalog labels | Rounded 16dp, bold 24sp typography |
| `CustomerUtangCard` | Displays customer name, debt balance, quick action buttons | High contrast card with red debt balance |
| `ProductStockRow` | Displays thumbnail/icon, product name, quantity, restock alert | Fast rendering list item with +/- stepper |
| `SariMessageBubble` | Chat bubble representing "Sari" with avatar and friendly text | Warm yellow/amber accent, rounded corners |
| `ConfirmActionDialog` | Modal showing parsed voice transaction for user verification | Big "Oo, Tama" (Yes) and "Kanselahin" (Cancel) |
