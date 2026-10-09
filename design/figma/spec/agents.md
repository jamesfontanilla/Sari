# Rules for AI Coding Agents

Point Cursor, Copilot, Devin or Claude Code here. The root `AGENTS.md` (loaded by `CLAUDE.md`) links to this file.

## 1. Project context

- App: **Sari**, an AppBuildersPH Hackathon 2026 entry (Local AI theme).
- All core AI inference **must run on-device**.
- Build window: 19.5 hours. **Priority: working demo > feature completeness > code elegance.**

## 2. Process rules

1. **Spec first.** Update the relevant `spec/` document and add an `## Unreleased` entry in `spec/CHANGELOG.md` *before* writing code. Then implement, verify, and date the entry. See [index.md](index.md).
2. Verify every UI change in the running app at phone width (375px) before calling it done.

## 3. Architecture rules

- **NEVER** call cloud AI APIs (OpenAI, Anthropic, Google, etc.) for core features.
- AI goes through the service interfaces in `src/services/`. Swap the stand-ins for Whisper, Llama, or ONNX without touching screens.
- On-device storage (`src/data/store.ts`, later IndexedDB/SQLite) is the only data store. No external databases.
- No runtime network requests: no CDNs, no Google Fonts (fonts come from `@fontsource`), no analytics.
- The service worker must cache the app shell (`public/sw.js`). Bump `CACHE` when changing precache behavior.
- All UI copy is in Filipino/Tagalog; Taglish is fine. English only for proper nouns, numbers, and established Taglish terms ("Low Stock", "Home").

## 4. Code standards

- TypeScript, React function components, default exports for screens and components.
- Format with **oxfmt** (`pnpm format`). It is this repo's formatter, in place of Prettier.
- Layout: `data/` (types, seed, store), `services/` (pure logic, no React), `components/`, `screens/`.
- Use double quotes for strings that contain apostrophes; close every JSX tag.
- No `console.log` in committed code.
- Commit messages: `feat:`, `fix:`, `docs:`, `style:`, `refactor:`.

## 4.1 Document references

| Need | Read |
| --- | --- |
| Product requirements | [prd.md](prd.md) |
| Architecture, data, services | [system-design.md](system-design.md) |
| User expectations and done-ness | [user-stories.md](user-stories.md) |
| Screens and navigation | [sitemap.md](sitemap.md) |
| Design, copy, mascot | [brands.md](brands.md) |
| Overview | [index.md](index.md) |

## 5. MVP priorities (build order)

1. Data schema + CRUD ✅ (`store.ts`)
2. Voice input → transcription ⏳ (simulated; Whisper WASM next)
3. Transaction parsing (utang, sale, payment) ✅ (rule-based; LLM next)
4. Dashboard with today's summary ✅
5. Camera → vision → inventory detection 🟡 (simulated)
6. Chat for business insights ✅ (rule-based)
7. Polish, animations, onboarding ✅

## 6. Do NOT build

- Authentication or login
- Cloud sync (post-hackathon)
- Languages beyond Tagalog/Taglish
- Analytics or telemetry
- In-app purchases or monetization
