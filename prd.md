# Product Requirements Document (PRD) — Sari

**Hackathon:** AppBuildersPH Hackathon 2026  
**Track:** Consumer App — Micro-Retail / Financial Literacy  
**Theme:** Local AI  
**Version:** v1.0 — Approved Spec (Option B: Native Mobile Architecture)  

---

## 1. Executive Summary
The Philippines is home to 1.3 million sari-sari stores, driving ₱1.1–1.4 trillion in annual sales and accounting for 70% of manufactured food product sales. Run predominantly by resourceful micro-entrepreneurs like **Aling Maria**, these stores form the bedrock of the neighborhood economy. Yet, most store owners track inventory on napkins or notebooks, calculate debts (*utang*) from memory, and operate with zero software support.

**Sari** is a mobile AI assistant running **100% on-device** on an Android phone. Using voice commands in Tagalog/Bisaya and camera vision, Aling Maria can record sales, log customer utang, track inventory, and ask *"Kumikita ba ako ngayon?"*—all processed locally, instantly, and with zero subscription or cloud dependencies.

> ### 🏆 The Mandatory Hackathon Answer (Memorize This)
> *"Why does this product benefit from running AI locally? Because the 1.3 million sari-sari store owners in the Philippines cannot afford cloud AI subscriptions, do not have reliable internet, and should not need to send their livelihood data to a server to run their business. Remove the local AI, and this product cannot exist for its intended users."*

---

## 2. Problem Statement
### The Problem (5th Grader Test)
> *"Sari-sari store owners lose money every day because they track inventory, sales, and customer debts in their head or on paper — and they have no internet or budget for business software."*

### Problem Validation Framework (The 5 Tests)
- **Real:** 1.3M active stores in PH; DTI launched the Sari-Sari Store Advancement Program acknowledging manual recording failures and high failure rates.
- **Large:** ₱1.1–₱1.4 Trillion annual sales; projected ₱2.4T by 2030; 93% in residential barangays.
- **Significant:** Crisis-proof, essential goods distribution (*tingi* model).
- **Urgent:** High failure rates within the first few weeks due to uncollected utang and mismanagement.
- **Relevant:** Directly fits the Local AI theme and resonates emotionally with every Filipino judge.

### The Five Whys (Root Cause Analysis)
1. *Why do stores fail?* -> Poor cashflow tracking and uncollected utang.
2. *Why poor tracking?* -> Owners use physical notebooks and memory.
3. *Why no business apps?* -> Existing tools demand reliable internet, subscriptions, and English fluency.
4. *Why can't they use cloud apps?* -> Prepaid data is expensive/unreliable, and store margins (₱300-₱700/day revenue) cannot bear SaaS costs.
5. **Root Cause:** No offline-first, Filipino-speaking, voice-first local AI assistant has been built for their hardware reality.

### Ideal Customer Profile (ICP)
- **Name:** Aling Maria, 45 years old
- **Location:** Barangay Poblacion (provincial / semi-urban)
- **Store Details:** Front of residence, ~₱5,000 revolving fund, sells sachet goods, canned goods, rice, softdrinks, prepaid load.
- **Daily Revenue:** ₱300 – ₱700/day.
- **Tech Reality:** Budget Android phone (3GB–4GB RAM), intermittent prepaid mobile data, uses GCash and FB voice messages.
- **Software Budget:** ₱0/month permanently.

---

## 3. Core Feature Set (MVP Scope — The 3 Pillars)

### Feature 1: 🗣️ Voice Bookkeeper (Sales & Utang Ledger)
- **Input:** Voice command in Tagalog, Taglish, or Bisaya (e.g., *"Si Mang Juan utang 150 sardinas at bigas"*, *"Nagbayad si Maria ng 200"*).
- **AI Layer:** Local speech recognition (Whisper model) + Local NLP/LLM transaction parser.
- **Output:** Structured SQLite ledger entry (Utang record, Sale, or Payment) confirmed verbally by Sari.

### Feature 2: 📸 Snap & Track (Inventory Vision & OCR)
- **Input:** Camera snapshot of shelf stock or supplier receipt.
- **AI Layer:** Local vision model (ONNX / TFLite MobileNet / YOLO / ML Kit OCR).
- **Output:** Automatic inventory quantity update, buy-price capture, and low-stock warning triggers.

### Feature 3: 💡 Sari Insights (Conversational Business Brain)
- **Input:** Natural query in Tagalog (e.g., *"Kumikita ba ako ngayon?"*, *"Sino may pinakamalaking utang?"*).
- **AI Layer:** Local LLM with SQLite query/context injection.
- **Output:** Direct, conversational, empowering business advice in Filipino.

---

## 4. The 4 Pillars: Why Cloud Cannot Work Here
| Pillar | Reality | Consequence if Cloud |
|---|---|---|
| **Impossible** | Intermittent or absent connectivity in residential barangays. | App displays "No Connection" error when customers are in line. |
| **Expensive** | Micro-stores make ₱500/day; cloud API costs would consume 10-20% of profits. | Zero viable business model for micro-retailers. |
| **Private** | Daily income, debt records of neighbors, and supplier costs are deeply sensitive. | Owners refuse to upload personal community credit data. |
| **Slow** | Cellular round trips take 2–5 seconds; voice needs sub-second response. | Breaks conversational flow during real transactions. |

---

## 5. Hackathon Submission Criteria & Target Awards
- **Target Awards:** Grand Champion (₱100k), Best Local AI Award (₱50k), People's Choice (₱25k), Tutorials Dojo Financial Literacy Award.
- **Must Pass Demo Day Test:** App operates seamlessly on an Android device set to **Airplane Mode**.
