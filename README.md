# 🏪 Sari — The Sari-Sari Business Brain

> **100% Offline, Voice-First AI Assistant & Smart Ledger for Philippine Micro-Retailers**  
> *Built for AppBuildersPH Hackathon 2026 (Local AI Theme)*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Android](https://img.shields.io/badge/Android-16_ARM64-3DDC84?logo=android)](https://developer.android.com)
[![Offline First](https://img.shields.io/badge/Network-100%25_Offline-16A34A)](#airplane-mode-guarantee)
[![License](https://img.shields.io/badge/License-MIT-EA580C)](#license)

---

## 📌 Executive Summary

Across the Philippines, over 1.3 million *sari-sari stores* power the neighborhood economy. Yet nearly 90% still rely on worn *kuwaderno* notebooks, resulting in lost credit tracking (*utang*), unrecorded cash sales (*benta*), and stockouts.

**Sari** transforms any low-cost Android phone into an intelligent, voice-driven **Point-of-Sale (POS) & Business Brain**. Operating **100% offline in Airplane Mode**, Sari speaks and understands natural, colloquial Filipino/Taglish, keeping small store owners in total control of their livelihood with **zero cloud dependencies, zero data costs, and complete privacy**.

---

## 🌟 Key Features

### 1. 🎙️ 0ms Voice Ledger (*Salita-sa-Tala*)
* **Natural Tagalog/Taglish Dictation:** Storekeepers tap the floating mic and say:
  * *"Si Mang Juan Dela Cruz utang 150 sardinas"*
  * *"Nagbayad si Aling Rosa ng 200"*
  * *"Benta ko 45 pancit canton"*
* **Lightning-Fast Parsing:** Powered by a deterministic 0ms Tagalog NLP parser paired with local speech engines. Transactions write directly to SQLite, play an authentic cash register chime (*"ka-ching!"*), and confirm verbally via Filipino TTS.

### 2. 📸 Snap & Track Camera Scanner (*Kamera Paninda*)
* **Real-World EAN-13 Barcodes:** Pre-seeded with authentic barcodes for 20 iconic sari-sari items (Lucky Me! Pancit Canton, Mega Sardines, Century Tuna, Kopiko Blanca, Bear Brand, Coca-Cola).
* **1-Tap Dynamic Barcode Linking:** Scanning any unmapped barcode off a shelf immediately displays an *"I-link sa Paninda"* selector, registering new stock in 1 second.
* **Shelf Vision AI ("I-snap ang Istante"):** Rapid multi-item inventory detection for bulk stock counting.

### 3. 📖 Suki Credit Ledger (*Talaan ng Utang*)
* **Individual Customer Ledgers:** Balances and transaction history timelines for neighborhood suki.
* **One-Touch Payment Chips:** Instant repayment logging with pre-calculated chips (**₱50**, **₱100**, **₱200**, **Buo / Full**), auto-updating outstanding balances in real time.

### 4. 🧠 Sari Business Brain (*Tanong kay Sari*)
* **Live Financial Telemetry:** Store owners ask:
  * *"Kumikita ba ako?"* → Computes today's sales and estimated ~22% net profit margin.
  * *"Sino may pinakamalaking utang?"* → Ranks highest outstanding suki balances for collection.
  * *"Ano ang paubos na paninda?"* → Identifies goods below reorder thresholds.
* **Dual-Engine Architecture:** Local LLM reasoning pipeline (Llama 3.2 3B Instruct) paired with deterministic financial query fallbacks for resilient offline execution.

### 5. ⚙️ Demo Rehearsal & Reset (*I-reset ang Demo Tindahan*)
* Dedicated Settings tab with a **1-click reset button** restoring 20 starter products and 3 customer profiles to pristine demo states for testing and judge presentations.

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Sari Presentation Layer                  │
│       Tindahan  •  Utang  •  Paninda  •  Sari AI  •  Setting │
└──────────────────────────────┬──────────────────────────────┘
                               │
       ┌───────────────────────┴───────────────────────┐
       ▼                                               ▼
┌─────────────────────────────┐         ┌─────────────────────────────┐
│      Audio & Vision IO      │         │   On-Device Intelligence    │
│ • Speech-to-Text (STT)      │         │ • Deterministic NLP (0ms)   │
│ • Camera / Mobile Scanner   │         │ • Llama 3.2 3B Instruct     │
│ • AudioFeedback (Ka-Ching!) │         │ • Whisper Speech Engine     │
│ • Filipino TTS Voice        │         │ • Local Insights Engine     │
└──────────────┬──────────────┘         └──────────────┬──────────────┘
               │                                       │
               └───────────────────────┬───────────────┘
                                       ▼
┌─────────────────────────────────────────────────────────────┐
│                 Local Embedded SQLite Database               │
│      products  •  customers  •  transactions  •  items       │
└─────────────────────────────────────────────────────────────┘
```

---

## ✈️ The Airplane Mode Guarantee

> **Strict Prime Directive:** Under NO circumstances does Sari make outbound cloud calls to OpenAI, Anthropic, Google Gemini, or remote inference servers.

* ✅ **100% On-Device:** All AI reasoning, entity extraction, text-to-speech, and database operations run locally on the phone's CPU/GPU via Android runtimes.
* ✅ **Zero Latency:** Transactions log in **<50 milliseconds**.
* ✅ **Zero Data Cost:** Runs indefinitely with mobile data, Wi-Fi, and SIM cards removed or in Airplane Mode.

---

## 📦 Project Structure

```
lib/
├── core/
│   ├── database/
│   │   └── database_helper.dart      # SQLite schema, 20 EAN-13 products & suki fixtures
│   ├── models/
│   │   ├── customer.dart             # Suki customer profile & utang balance model
│   │   ├── product.dart              # Inventory SKU, pricing, barcodes & thresholds
│   │   └── transaction.dart          # Sales, debt, repayment & restock records
│   ├── nlp/
│   │   └── tagalog_nlp_parser.dart   # Deterministic 0ms Tagalog/Taglish regex parser
│   └── services/
│       ├── audio_feedback_service.dart# Cash register chime & barcode beep player
│       ├── llama_service.dart        # On-device AI intelligence & telemetry synthesis
│       └── speech_service.dart       # Local microphone STT & Filipino TTS playback
├── features/
│   ├── ledger/
│   │   └── customer_detail_screen.dart # Suki transaction timeline & 1-tap payment chips
│   ├── scanner/
│   │   └── scanner_screen.dart       # Camera viewfinder, flash toggle & barcode link
│   └── settings/
│       └── settings_screen.dart      # 1-click demo database reset tool & AI readiness
└── main.dart                         # 5-tab POS dashboard & live reactive state
```

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (3.24+ recommended)
* Android SDK (API 34+)
* Physical Android phone (Developer Options & USB Debugging enabled)

### Running on Physical Device

1. **Clone the repository:**
   ```bash
   git clone https://github.com/jamesfontanilla/Sari.git
   cd Sari
   ```

2. **Fetch Flutter packages:**
   ```bash
   flutter pub get
   ```

3. **Deploy to connected Android phone:**
   ```bash
   flutter run -d <your-device-id>
   ```

4. **Verify Offline Mode:**
   Turn on **Airplane Mode** on your phone. Record voice transactions, scan barcodes, and query Sari AI — everything continues functioning flawlessly with 0ms latency.

---

## 👥 Hackathon Team & Credits

* **Developer:** [James Fontanilla](https://github.com/jamesfontanilla)
* **Hackathon:** AppBuildersPH Hackathon 2026
* **Theme:** Local AI & On-Device Micro-Commerce

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
