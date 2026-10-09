# Sari — Spec Index

> Start here. This folder is the source of truth for the app. Code follows the spec, not the other way around.

## Project overview

| | |
| --- | --- |
| **App name** | **Sari**. The title everywhere (UI, page title, PWA manifest) is "Sari"; the old "Sari-Sari Business Brain" is retired. |
| **Tagline** | "Ang iyong AI tindera, nasa bulsa mo." / "Your AI tindera, right in your pocket." |
| **Hackathon** | AppBuildersPH Hackathon 2026, Local AI theme |
| **Build window** | Oct 9, 2:30 PM to Oct 10, 10:00 AM (19.5 hours) |
| **Demo Day** | Oct 10, 1:00–7:00 PM, Cyberzone, SM Makati |
| **Judging** | 25% Problem & Usefulness · 25% Local AI Implementation · 20% Technical Execution · 15% Innovation · 15% Product & Demo Quality |

## Workflow: spec first, then code

1. **Update the spec.** Edit the relevant document(s) below and add an entry under `## Unreleased` in [CHANGELOG.md](CHANGELOG.md).
2. **Implement** the code so it matches the spec.
3. **Verify** in the running app (`pnpm dev`, http://localhost:8443, at phone width).
4. **Close out.** Move the changelog entry under a dated heading, and fix the spec if implementation proved it wrong.

If code and spec disagree, treat it as a bug in one of them and resolve it explicitly.

## Document map

| # | File | Purpose | When to consult |
| --- | --- | --- | --- |
| 1 | `index.md` | This file, the master navigation | First. Always start here. |
| 2 | [prd.md](prd.md) | Product requirements: WHAT and WHY | Scoping a feature, or answering a judge |
| 3 | [system-design.md](system-design.md) | Architecture, data model, services, offline: HOW | Touching state, logic, or AI/services |
| 4 | [user-stories.md](user-stories.md) | Stories, acceptance criteria, implementation status | Deciding when something is "done" |
| 5 | [sitemap.md](sitemap.md) | Screens, navigation, components: WHERE | Any UI or screen work |
| 6 | [agents.md](agents.md) | Rules for AI coding agents | Before writing any code |
| 7 | [brands.md](brands.md) | Brand, voice and tone, design system, mascot, ICP behavior | Any design, copy, or UX decision |
| — | [CHANGELOG.md](CHANGELOG.md) | Dated history of spec and code changes | Seeing what changed and why |

## Sources

- PRD: `sari_sari_business_brain_prd.docx` (v1.0, Oct 2026), kept outside the repo
- Foundational Matrix Documents outline: `[Outline] Sari — Complete Foundational Matrix Documents (7 FMDs)` (Oct 9, 2026)
- UI mockup: 12-panel board (Welcome, Dashboard, Voice, Snap & Track, Insights, Ledger, Inventory, Brand, Offline)
- Mascot assets: Canva "Sari-Sari" design (https://canva.link/74dufvo2xdcf22a, `DAHXg_0eqeU`)
- AppBuildersPH Hackathon 2026 Participant Briefing (judging, rules, submission)

## Quick links

- GitHub repo: *to be created*
- Submission: cerebralvalley.ai/e/appbuildersph-hackathon-2026
- Telegram: t.me/+uxlZLV5_jEZjMDNl
