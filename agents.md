# AI Coding Agent Directives — Sari

**Audience:** AI Coding Assistants (Cursor, Claude, Copilot, Gemini, Devin).  
**Primary Objective:** Deliver a rock-solid, crash-proof, 100% offline mobile app for Demo Day.

---

## 1. Prime Directives (Non-Negotiable)

1. **ZERO CLOUD AI CALLS:**
   - Under NO circumstance should you import or make HTTP requests to OpenAI, Anthropic, Google Gemini API, Groq, Replicate, or any remote AI endpoint.
   - All AI inference, parsing, NLP, and database operations MUST happen entirely on the local device or inside local background isolates/runtimes.
2. **DEMO OVER ARCHITECTURAL COMPLEXITY:**
   - A flawless, working demo running in Airplane Mode beats a complex, broken NDK integration every time.
   - Implement deterministic Tagalog NLP parsers as a lightning-fast primary/fallback pipeline alongside on-device models. If an on-device LLM model is loading or constrained, the app must NEVER freeze or crash.
3. **PRESERVE SARI'S PERSONALITY & LANGUAGE:**
   - All user-facing strings, toasts, confirmations, and chat outputs MUST be in natural colloquial Tagalog/Taglish.
   - Do NOT use robotic corporate chatbot phrasing. Speak like a helpful neighborhood *tindera* (see `brands.md`).

---

## 2. Coding Standards & Guidelines

### Flutter / Dart Standards (Option B)
- **Architecture:** Feature-first or clean layered architecture (`core/`, `features/inventory/`, `features/ledger/`, `features/voice_nlp/`, `features/insights/`).
- **State Management:** Riverpod or lightweight Provider/ChangeNotifier for speed, testability, and clarity.
- **Local Database:** `sqflite` (SQLite on Android) with pre-seeded demo fixtures.
- **Error Handling:** All voice, camera, and parsing flows must be wrapped in `try/catch` with graceful Tagalog user feedback (*"Pasensya na, hindi ko narinig nang maayos. Subukan ulit!"*).

### Git & Commit Conventions
- Use conventional commits:
  - `feat: add voice transaction parser for utang and sales`
  - `feat: add local sqlite schema and 20 sari-sari starter products`
  - `ui: style home dashboard with big voice action button`
  - `fix: ensure offline mode works with zero internet permissions`

---

## 3. What NOT to Build (Strictly Out of Scope)
- ❌ User authentication, sign-up, login, SMS OTP, or passwords.
- ❌ Cloud synchronization, Firebase Auth, Supabase sync.
- ❌ External payment gateway integrations (no Stripe, PayMongo, etc.).
- ❌ Complex accounting features (depreciation, multi-branch, employee payroll).
- ❌ In-app subscriptions or ads.

---

## 4. Priority Implementation Sequence
1. **Database & Models:** SQLite initialization, tables (`products`, `customers`, `transactions`, `transaction_items`), and seeding 20 iconic sari-sari goods.
2. **Deterministic & Local NLP Parser:** Regex + keyword parser that can parse 100% of the demo voice scripts accurately in 0ms.
3. **Core UI Dashboard & Ledger:** Big buttons, real-time counters, utang list.
4. **Speech & Audio Integration:** Microphone listener & audio capture pipeline.
5. **Insights Engine:** Querying SQLite to answer *"Kumikita ba ako?"* and *"Sino may pinakamalaking utang?"*.
6. **Camera / Vision Stub & Scanner:** Shelf item detection or barcode/image capture.
