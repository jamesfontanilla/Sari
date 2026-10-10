# 🏪 Sari — The Sari-Sari Business Brain

> **100% Offline, Voice-First AI Assistant & Smart Ledger for Philippine Micro-Retailers**  
> *Built for AppBuildersPH Hackathon 2026 — Local AI Theme*

[![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter)](https://flutter.dev)
[![Android](https://img.shields.io/badge/Android-10+-3DDC84?logo=android)](https://developer.android.com)
[![Offline First](https://img.shields.io/badge/Network-100%25_Offline_Airplane_Mode-16A34A)](#-the-airplane-mode-guarantee)
[![Download APK](https://img.shields.io/badge/Download_APK-Google_Drive-EA4335?logo=googledrive&logoColor=white)](https://drive.google.com/file/d/1Lk5Ypf8L4ZXcOElyQK6olnAms0Qyli1w/view?usp=sharing)
[![License](https://img.shields.io/badge/License-MIT-EA580C)](LICENSE)
[![Hackathon Submission](https://img.shields.io/badge/Hackathon-AppBuildersPH_2026-6366F1)](SUBMISSION.md)

---

## 📌 Executive Summary

Across the Philippines, over **1.3 million *sari-sari stores*** power the neighborhood economy, accounting for over **₱1.1 Trillion** in annual retail sales. Yet nearly 90% of store owners (*Aling Maria*) still rely on weathered paper notebooks (*kuwaderno*) or memory, leading to lost debt collections (*utang*), unrecorded cash sales (*benta*), and frequent stockouts.

**Sari** transforms any low-cost Android smartphone into an intelligent, voice-driven **Point-of-Sale (POS), inventory tracker, and business brain**. Operating **100% offline in Airplane Mode**, Sari speaks and understands natural colloquial Filipino/Taglish, keeping small store owners in total control of their livelihood with **zero cloud dependencies, zero data costs, and complete financial privacy**.

> 📲 **Judges & Evaluators Quick Install:**  
> **[📥 Download Sari Demo APK (Google Drive)](https://drive.google.com/file/d/1Lk5Ypf8L4ZXcOElyQK6olnAms0Qyli1w/view?usp=sharing)** — Install directly on any Android 10+ device and test in 100% Airplane Mode!  
> 👉 **Official Hackathon Submission Details: See [SUBMISSION.md](SUBMISSION.md).**

---

## 🏆 AppBuildersPH Hackathon 2026 Submission Checklist

| Checklist Requirement | Project Detail |
| :--- | :--- |
| **Project Name** | **Sari** — The Sari-Sari Business Brain |
| **Short Description** | 100% offline, voice-driven AI assistant and smart ledger for Philippine micro-retailers to track sales, utang, inventory, and market restocks in colloquial Tagalog. |
| **Team Members** | **James Fontanilla** ([@jamesfontanilla](https://github.com/jamesfontanilla)) — Lead Developer<br>**Melfred Bernabe** ([@caramel-123](https://github.com/caramel-123)) — Lead Designer |
| **Public GitHub Repository** | [https://github.com/jamesfontanilla/Sari](https://github.com/jamesfontanilla/Sari) |
| **Pre-built Demo APK** | [**Download Sari APK on Google Drive**](https://drive.google.com/file/d/1Lk5Ypf8L4ZXcOElyQK6olnAms0Qyli1w/view?usp=sharing) |
| **Demo Video** | *[Insert Demo Video Link Here — e.g., YouTube / Google Drive / Loom]* |
| **X / LinkedIn Video URL** | *[Insert X / LinkedIn Post URL Here]* |
| **What Runs Locally** | 100% of speech recognition, Tagalog NLP parsing, Filipino TTS synthesis, barcode vision scanning, LLM reasoning, SQLite queries, and telemetry analytics. |
| **What Requires Internet** | **0% (None).** Works flawlessly in strict Airplane Mode without cellular, Wi-Fi, or SIM cards. |
| **Models Used** | Llama 3.2 3B Instruct (GGUF), Whisper Base (STT), Google ML Kit Barcode Vision (on-device), Android Native On-Device TTS (`fil-PH`). |
| **Technologies & Frameworks**| Flutter 3.24+, Dart, SQLite (`sqflite`), Android NDK (ARM64), `flutter_tts`, `mobile_scanner`, `audioplayers`, `shared_preferences`. |
| **APIs and Cloud Services** | **None (0).** Zero external API keys, zero cloud endpoints, zero remote telemetry. |
| **Existing Code & Assets** | Custom mascot animations/illustrations (`assets/sari/`), 20 pre-seeded Philippine FMCG barcodes, open-source icons. |
| **AI Development Tools** | Antigravity (Google DeepMind) and Gemini Code Assist. |

---

## 💡 Mandatory Question: Why Does This Product Benefit From Running AI Locally?

> ### 📢 The Core Answer
> *"The 1.3 million sari-sari store owners in the Philippines cannot afford cloud AI subscriptions, do not have reliable internet in neighborhood barangays, and should not need to send their livelihood data to a remote server to run their business. Remove the local AI, and this product cannot exist for its intended users."*

### Key Pillars:
1. **Zero Data Overhead (The *Tingi* Economy):** Sari-sari stores operate on micro-margins (₱300–₱700 daily profit selling ₱15 items). Forcing Aling Maria to burn paid mobile data (₱50/GB load) to record transactions destroys unit economics. Local AI costs ₱0.00 in bandwidth.
2. **100% Uptime in Rural and Interior Barangays:** Many stores sit in dense urban alleys or provincial barangays with spotty or zero cellular coverage. Cloud AI fails during peak customer hours or typhoons; local AI works 24/7/365.
3. **Sub-50ms Retail Flow:** Neighborhood store owners cannot wait 3 to 5 seconds for a cloud LLM to stream. Sari's on-device NLP parses voice transactions in **<10ms** with instant SQLite writes and real-time audio chime (*"ka-ching!"*).
4. **Complete Financial Privacy:** Suki credit ledgers contain sensitive neighborhood debt relationships. With local AI and SQLite, data never leaves the owner's phone.
5. **No Recurring Token Bills:** Cloud AI APIs charging per token are unviable for free micro-retail software. Local models scale infinitely on the phone's CPU/GPU at zero marginal compute cost.

---

## 📸 Product Walkthrough & Screenshots

| 1. Dashboard & Voice POS | 2. Animated Onboarding | 3. Voice POS Tutorial | 4. Barcode & Shelf Scanner |
| :---: | :---: | :---: | :---: |
| <img src="docs/screenshots/01_dashboard.png" width="220" /> | <img src="docs/screenshots/02_welcome_onboarding.png" width="220" /> | <img src="docs/screenshots/03_tutorial_voice.png" width="220" /> | <img src="docs/screenshots/04_tutorial_scanner.png" width="220" /> |

---

## 🌟 Key Features

### 1. 🎙️ 0ms Voice Ledger (*Salita-sa-Tala*)
* **Natural Tagalog/Taglish Dictation:** Storekeepers tap the floating mic and speak naturally:
  * *"Si Mang Juan Dela Cruz utang 150 sardinas"*
  * *"Nagbayad si Aling Rosa ng 200"*
  * *"Benta ko 45 pancit canton"*
* **Lightning-Fast Parsing:** Powered by a deterministic 0ms Tagalog NLP parser paired with local speech engines. Transactions write directly to SQLite, play an authentic cash register chime (*"ka-ching!"*), and confirm verbally via native Filipino TTS.

### 2. 📸 Snap & Track Camera Scanner (*Kamera Paninda*)
* **Authentic EAN-13 Barcodes:** Pre-seeded with real-world barcodes for 20 iconic sari-sari items (Lucky Me! Pancit Canton, Mega Sardines, Century Tuna, Kopiko Blanca, Bear Brand, Coca-Cola).
* **1-Tap Dynamic Barcode Linking:** Scanning any unmapped barcode off a shelf immediately displays an *"I-link sa Paninda"* selector, registering new stock in 1 second.
* **✏️ Manu-mano Shelf Adjustment:** Quick bottom-sheet editor with search, `+` / `−` steppers, and direct numerical inputs for manual shelf stock updates.

### 3. 📖 Suki Credit Ledger (*Talaan ng Utang*)
* **Individual Customer Ledgers:** Balances, contact details, and transaction history timelines for neighborhood suki.
* **One-Touch Payment Chips:** Instant repayment logging with pre-calculated chips (**₱50**, **₱100**, **₱200**, **Buo / Full**), auto-updating outstanding balances in real time.

### 4. 🛒 Pamamalengke Restock Planner (*Listahan sa Palengke*)
* **Automatic Low-Stock Detection:** Pulls all inventory at or below minimum reorder thresholds.
* **Capital & Budget Validator:** Computes total *puhunan* needed, total pieces, and validates against *"Dala kong Pera"* to alert for budget surplus or shortage.
* **Market Checklist & 1-Tap Restock:** Interactive checklist during shopping trips, plus a single *"Nabili Ko Na Lahat! (I-restock)"* button that bulk-updates SQLite inventory with sound feedback.
* **Quick Clipboard Export:** Copy formatted restock lists for SMS/Messenger with a single tap.

### 5. 🧠 Sari Business Brain (*Tanong kay Sari*)
* **Live Financial Telemetry:** Store owners ask:
  * *"Kumikita ba ako?"* → Computes today's sales and estimated net profit margin.
  * *"Sino may pinakamalaking utang?"* → Ranks highest outstanding suki balances for collection.
  * *"Ano ang paubos na paninda?"* → Identifies goods below reorder thresholds.
* **Dual-Engine Architecture:** Local LLM reasoning pipeline (Llama 3.2 3B Instruct) paired with deterministic financial query fallbacks for resilient offline execution.

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Sari Presentation Layer                  │
│       Tindahan  •  Utang  •  Paninda  •  Sari AI  •  Setting │
└──────────────────────────────┬──────────────────────────────┘
                               │
        ┌──────────────────────┴──────────────────────┐
        ▼                                             ▼
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
│   ├── inventory/
│   │   └── pamamalengke_screen.dart  # Low-stock restock planner & budget calculator
│   ├── ledger/
│   │   └── customer_detail_screen.dart # Suki transaction timeline & 1-tap payment chips
│   ├── scanner/
│   │   └── scanner_screen.dart       # Camera viewfinder, barcode scan & manual input
│   └── settings/
│       └── settings_screen.dart      # 1-click demo database reset tool & guide replay
└── main.dart                         # 5-tab POS dashboard & live reactive state
```

---

## 🚀 Getting Started
 
### 📲 Option A: Direct APK Install (Recommended for Judges & Quick Testing)
1. Download the pre-compiled debug APK directly to your Android device:  
   👉 **[Download Sari APK (Google Drive)](https://drive.google.com/file/d/1Lk5Ypf8L4ZXcOElyQK6olnAms0Qyli1w/view?usp=sharing)**
2. Tap the downloaded APK to install (enable *"Install unknown apps"* if prompted).
3. Turn on **Airplane Mode** and launch **Sari**!

---

### 💻 Option B: Build & Run from Source

#### Prerequisites
* Flutter SDK (3.24+ recommended)
* Android SDK (API 34+)
* Physical Android phone (Developer Options & USB Debugging enabled)

#### Running on Physical Device

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

* **James Fontanilla** — Lead Developer ([@jamesfontanilla](https://github.com/jamesfontanilla))
* **Melfred Bernabe** ([caramel-123](https://github.com/caramel-123)) — Lead Designer
* **Hackathon:** AppBuildersPH Hackathon 2026
* **Theme:** Local AI & On-Device Micro-Commerce

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
