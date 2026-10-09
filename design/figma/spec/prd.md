# PRD — Product Requirements

## 1. Executive summary

Sari is a free, fully offline AI assistant for Filipino sari-sari store owners. It uses local speech recognition, local vision, and a local LLM to help micro-retailers track inventory, manage utang (customer credit), log sales, and get business insights, all through Tagalog voice commands and camera snaps. No internet. No subscription. No data leaves the phone.

**Mandatory hackathon answer (verbatim):**
> "Why does this product benefit from running AI locally? Because the 1.3 million sari-sari store owners in the Philippines can't afford cloud AI subscriptions, don't have reliable internet, and shouldn't need to send their livelihood data to a server to run their business. Remove the local AI, and this product cannot exist for its intended users."

**Prize targets:** Grand Champion, AMD Best Local AI, People's Choice, Tutorials Dojo.

## 2. Problem

**One sentence (5th-grader test):** "Sari-sari store owners lose money every day because they track everything in their head or on paper — and they have no internet or budget for business software."

### Five tests

| Test | Evidence |
| --- | --- |
| **Real** | 1.3M sari-sari stores in the PH, run with notebooks and mental math. DTI launched the Sari-Sari Store Advancement Program (June 2024). Many stores close within weeks due to "management mishandling." |
| **Large** | ₱1.1–1.4T in annual sales; 70% of manufactured consumer food sales; projected ₱2.4T by 2030; 213K+ stores transacting digitally via Packworks in 2025 (+21% YoY) |
| **Significant** | Resilient through downturns (tingi buying); 93% are located in residential communities |
| **Urgent** | DTI digitalization is underway now but tools are lacking; the AI tools entering the space all require internet |
| **Relevant** | Government push; AI helps owners "identify underperforming products and make better decisions" (Kadence International PH) |

### Five whys (root cause)

1. Stores fail because of poor financial management and forgotten debts.
2. Management is poor because the only tools are notebooks and memory.
3. There are no tools because existing apps need internet, subscriptions, and English literacy.
4. Cloud apps don't work because there is no reliable internet, no budget, and privacy concerns.
5. **Root:** no tool exists in a form that fits their reality: offline, free, Filipino-language, voice-first, simple.

### ICP: Aling Maria, 45

- Barangay Poblacion, a provincial town. Store in front of her house, with a ~₱5,000 revolving fund.
- Sells tingi: sachets, canned goods, cigarettes, soft drinks, load. Revenue is ₱300–700/day.
- **Pain:** about 30 suki with running utang, doesn't know which products are profitable, can't forecast restocks, illegible notebook.
- **Tech:** budget Android (4GB RAM), prepaid data, comfortable with Tagalog/Taglish voice, uses Facebook and GCash.
- **Software budget:** ₱0/month.

## 3. Solution

A free Android PWA (native app later) with a local AI assistant named **Sari**: a warm, slightly witty AI tindera inspired by Clucky's personality-driven UX and Tarsi's approachable finance UI. Voice first (Tagalog/Taglish), plus camera snaps. Everything is processed on-device.

### Three core features (MVP, no more)

1. **🗣️ Voice Bookkeeper**
   - Utang: "Si Mang Juan, utang 150 pesos, sardinas at bigas"
   - Sale: "Benta ko ngayon, 3 sardinas 45 pesos"
   - Payment: "Bayad ni Aling Rosa, 200 pesos"
   - Pipeline: speech, then parsing, then confirmation, then save to the ledger and sales record.
2. **📸 Snap & Track**
   - Shelf: the camera identifies products and estimates quantities, then updates inventory.
   - Receipt: snap a supplier receipt, OCR extracts items and costs, and it records a restock with buy prices.
3. **💡 Sari Insights**
   - Ask "Anong pinaka-mabenta ko this week?" or "Magkano utang lahat?" and get a plain Filipino answer.
   - Includes a daily profit summary, low-stock alerts, and an utang aging report.

## 4. Why local AI is fundamental

| | |
| --- | --- |
| **Impossible** | No reliable internet in many barangays; 93% of stores are in residential areas without WiFi |
| **Expensive** | ~$0.03/query × 50 queries/day ≈ ₱90/day, about 18% of daily revenue. Local AI has zero marginal cost. |
| **Private** | Finances, utang, and suppliers are sensitive, and competitors are neighbors. Data never leaves the phone. |
| **Slow** | Voice needs replies under 1 second; a 2–5 second cloud round-trip breaks the flow |

## 5. Competitor landscape

Competitors: Sari.PH Pro (Packworks), TingiFlow, Benta PH, Binta, Laki, Globe Benta, Owy PH, and the manual notebook.

| Product | Offline? | Free? | AI? | Voice-first? | Filipino? | Camera inventory? |
| --- | --- | --- | --- | --- | --- | --- |
| **Sari** | ✅ | ✅ | ✅ local | ✅ | ✅ | ✅ |
| Notebook | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ |
| Others | *to verify per product before the pitch; do not claim unverified features* | | | | | |

**Positioning:** POS apps (TingiFlow, Benta, Binta) are systems you tap through. Sari is an assistant you talk to. Tarsi covers personal finance, Sari covers micro-business, so they are complementary.

## 6. Success metrics (hackathon scope)

- The demo completes without a crash.
- Voice command to logged transaction in under 3 seconds.
- Camera snap to identified inventory in under 5 seconds.
- Business question to insight in under 5 seconds.
- All 3 features work in airplane mode.
- The team handles 3 minutes of judge Q&A confidently.

## 7. Submission checklist

- [ ] Project name and description
- [ ] Team members
- [ ] Public GitHub repo
- [ ] Demo video (~1 min)
- [ ] X/LinkedIn video tagging Devin/Cognition, with #AppBuildersPH
- [ ] What runs locally vs. what needs internet (see [system-design.md §7](system-design.md))
- [ ] Full disclosure: models, frameworks, APIs, cloud services, existing code, AI dev tools
- [ ] Mandatory answer (§1)

## 8. Current implementation status

This repo is a **working UI prototype** with on-device logic but **no ML models yet**:

| Capability | Status |
| --- | --- |
| Transaction parsing (utang / sale / payment / restock) | ✅ Local rule-based Tagalog/Taglish parser, standing in for the LLM |
| Insights Q&A | ✅ Local rule-based answers computed from real stored data, standing in for the LLM |
| Storage | ✅ On-device `localStorage`, surviving reloads (IndexedDB/SQLite is the target) |
| Offline | ✅ PWA manifest and service worker in production builds; fonts self-hosted |
| Speech-to-text | ⏳ Simulated: tap a sample phrase or type. Whisper WASM is pending. |
| Vision / OCR | ⏳ Simulated detections and receipt. ONNX model pending. |
