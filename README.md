# Vesper 🌿

> **Grow Together. Resolve Better. Appreciate Always.**

Vesper is a cross-platform relationship wellness app for couples — built to help partners communicate better during conflict, grow together through shared challenges, and celebrate each other every week. It is designed as a structured, intentional alternative to couples therapy apps that feel clinical, and appreciation tools that only scratch the surface.

---

## Why I Built This

Most relationship apps pick one lane — gratitude, education, or guided conversation. None of them give couples a tool for the hard moments *and* the good ones in the same place. Vesper is built around three systems that work together as a complete loop: resolve conflict, invest in growth, express appreciation. Repeat.

The idea started as a personal project and grew into a full product with a real architecture, database schema, and AI-powered features.

---

## Features

### 🕊️ Conflict Resolution System
An on-demand guided flow for when things get heated.

- **Breathing exercise** — 2-minute guided box breathing before any words are exchanged
- **Private emotion check-in** — each partner independently documents what they felt, what triggered it, what they need, and whether they are ready to talk
- **Peace signal** — instead of "we need to talk", partners send a gentle animated signal (a lily) when ready; the other responds with cookies. No loaded language.
- **Conversation framework** — structured guide covering acknowledgment, sharing, listening, root cause, needs, and future commitments
- **Optional voice recording** with AI transcription and summary via OpenAI
- **Resolution rating and follow-up scheduling**

### 🌱 Growth System
A monthly shared session where both partners invest in each other's development.

- Calendar invite sent 10 days in advance with rescheduling support
- Previous challenge review with honest accountability check-in
- Each partner privately sets a habit or challenge for the other
- AI-generated reveal presentation shown on a shared screen
- Support alignment — each partner specifies how they want to be helped
- Action items tracked on individual dashboards with weekly photo check-ins
- Alternating ownership cycles: partner-set goals then self-set goals

### ✨ Appreciation and Boasting Tracker
Weekly or twice-weekly prompts to keep positivity intentional.

- Three prompts: one appreciation for your partner, one personal win to boast about, three gratitudes
- Digital gift badge sent alongside each response (preset grid or AI-generated custom badge)
- Shared appreciation archive with full history and badge collection view

---

## Architecture and Tech Decisions

### Stack

| Layer | Technology | Why |
|---|---|---|
| Frontend | Flutter (via Dreamflow) | Single codebase for web and mobile with production-ready Flutter output |
| Backend | Supabase (PostgreSQL) | Relational integrity for partner linking, row-level security, edge functions, real-time support |
| Auth | Supabase Auth | Email, Google, Apple Sign-In with biometric support |
| File Storage | Supabase Storage | Profile photos, voice recordings, check-in photos |
| AI Badge Generation | OpenAI DALL-E 3 via Supabase Edge Function | Keeps API key server-side, allows moderation pre-processing before image generation |
| Push Notifications | Firebase Cloud Messaging | Peace signal delivery, growth date reminders, appreciation prompts |
| Deployment | Dreamflow (MVP) → custom Flutter/Node stack at scale | Validate product with real couples before investing in full custom infrastructure |

### Key Technical Decisions

**Why Supabase over Firebase**
Supabase gives us PostgreSQL with real relational integrity, which matters for the partner linking model. The `partner_ids` array with a GIN index works well at MVP scale. Row-level security policies let us enforce at the database level that partners can only access each other's data — something harder to achieve cleanly with Firestore rules at this level of relational complexity.

**Why JSONB for emotion check-ins**
Each conflict session stores private per-user state that is only revealed to both partners after the conversation framework begins. JSONB with a keyed structure per user_id keeps this in one row without creating a separate table for what is essentially a transient, session-scoped data structure.

**Why Edge Functions for AI image generation**
Calling the DALL-E API directly from the Flutter client would expose the API key. The Edge Function sits between the app and OpenAI, runs a content moderation pass first, prepends a style prompt for consistent illustrated badge aesthetics, then calls the image generation API. The generated image is stored in Supabase Storage and only the URL is returned to the client.

**Why a GIN index on partner_ids**
The most frequent query in the app is "find all records belonging to this couple." Since couple membership is stored as a UUID array, a standard B-tree index does not help with array containment queries. A GIN index makes `where auth.uid() = any(partner_ids)` fast even as the couples table grows.

**Planned migration path**
The MVP is scaffolded in Dreamflow to validate core user flows with real couples quickly. The production version will migrate to a custom Flutter frontend with a Node.js backend, at which point the Supabase schema and Edge Function patterns carry over directly.

---

## Database Schema

9 tables with row-level security enabled on all of them.

```
users
├── id (uuid, PK)
├── name, email, phone, date_of_birth
├── profile_photo_url, orientation
├── relationship_duration, relationship_feeling
├── biometric_enabled
└── linked_partner_ids (uuid[])

couples
├── id (uuid, PK)
├── partner_ids (uuid[], GIN indexed)
├── anniversary_date
├── growth_date_day, appreciation_frequency
└── current_growth_cycle

partner_link_requests
├── sender_id → users
├── receiver_id → users
└── status (pending, accepted, rejected)

conflict_sessions
├── couple_id → couples
├── initiator_id → users
├── emotion_checkins (JSONB — private per-user state)
├── peace_signal_status
├── recording_url (optional)
├── resolution_rating, ai_summary
└── status (open, in_progress, resolved)

growth_challenges
├── couple_id → couples
├── set_by_user_id, assigned_to_user_id → users
├── title, why_it_matters, how_i_can_help
├── complexity (small, medium, big)
├── start_date, target_date
└── status, progress_percent, photo_urls

growth_checkins
├── challenge_id → growth_challenges
├── user_id → users
├── actions_taken, note, photo_url
└── progress_percent

growth_sessions
├── couple_id → couples
├── scheduled_date, status
├── partner_1_confirmed, partner_2_confirmed
└── partner_1_review, partner_2_review (JSONB)

appreciation_entries
├── couple_id → couples
├── from_user_id, to_user_id → users
├── week_of
├── appreciation_text, win_text
├── gratitudes (text[])
├── badge_selected
└── viewed_at

notifications
├── user_id → users
├── type (growth_date_reminder, peace_lily_received, etc.)
├── data (JSONB)
└── read, read_at
```

> Table definitions are in [`lib/supabase/supabase_tables.sql`](./lib/supabase/supabase_tables.sql) and row-level security policies are in [`lib/supabase/supabase_policies.sql`](./lib/supabase/supabase_policies.sql).

---

## Roadmap

| Phase | Timeline | Scope |
|---|---|---|
| MVP | Month 1-2 | Core three features, onboarding, partner pairing, Dreamflow build, 10-50 beta couples |
| Phase 2 | Month 3-5 | AI transcription for conflict sessions, growth reveal presentation, app store submission |
| Phase 3 | Month 6-12 | Paid tiers, voice recording + cloud backup, AI custom badge maker via DALL-E Edge Function, 1,000 couples |
| Phase 4 | Year 2+ | Custom Flutter/Node stack migration, scale to 100K couples, B2B therapy partnerships |

---

## Feature Backlog

- **AI Custom Badge Maker** — user describes a badge in natural language, DALL-E generates a unique illustrated sticker sent as a gift to their partner. Prompt is style-prefixed for consistency and run through a moderation layer before reaching the image API. API key stays server-side via Supabase Edge Function.

---

## Project Structure

```
Vesper-Wellness-App-for-Couples/
├── android/                        # Android platform configuration
├── ios/                            # iOS platform configuration
├── web/                            # Web platform configuration
├── assets/                         # Images, fonts, and static assets
├── lib/                            # All Dart application code (93.7% of codebase)
│   ├── supabase/
│   │   ├── supabase_tables.sql     # Full database schema — all table definitions
│   │   ├── supabase_policies.sql   # Row-level security policies per table
│   │   ├── database.types.ts       # TypeScript type definitions for Edge Functions
│   │   ├── supabase_config.dart    # Flutter Supabase client configuration
│   │   └── migrations/             # Individual migration history from Dreamflow
│   └── ...                         # Feature modules, screens, services, theme
├── supabase/
│   └── functions/                  # TypeScript Edge Functions (5.5% of codebase)
│       └── generate-badge/         # AI badge generation via DALL-E (planned)
├── pubspec.yaml                    # Flutter dependencies
├── pubspec.lock
├── analysis_options.yaml
└── update_imports.sh
```

---

## Design System

```
Primary       #6D2E46   deep berry
Secondary     #A26769   dusty rose
Accent        #E8C4C4   blush
Background    #FDF6F0   warm cream
Conflict      #028090   teal
Growth        #84B59F   sage green
Appreciation  #C9974A   gold
```

Typography: Playfair Display (headings), Lato (body)

Responsive breakpoints: mobile under 600px, tablet 600-1024px, web above 1024px with persistent left sidebar.

---

## Getting Started (Local Development)

```bash
# Clone the repo
git clone https://github.com/rashmi1112/Vesper-Wellness-App-for-Couples.git
cd Vesper-Wellness-App-for-Couples

# Install Flutter dependencies
flutter pub get

# Set up environment variables
cp .env.example .env
# Add your Supabase URL and anon key


# Run the schema on your Supabase project
# Go to Supabase SQL Editor and run lib/supabase/supabase_tables.sql first
# Then run lib/supabase/supabase_policies.sql

# Run the app
flutter run -d chrome   # for web
flutter run             # for mobile
```

---

## Environment Variables

```
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

Never commit your `.env` file. It is included in `.gitignore`.

---

## Status

🚧 **Active development — MVP in progress**

Core features are being built and validated with a small group of beta couples. Architecture and schema are production-ready. Custom Flutter migration planned post-MVP validation.

---

## Author

**Rashmi** — Senior Software Engineer
Distributed systems, cloud infrastructure, AI-driven product development.

[LinkedIn](https://linkedin.com/in/your-profile) • [GitHub](https://github.com/rashmi1112) • [LogIQ Project](https://github.com/rashmi1112/LogIQ-AI-Powered-Log-Exploration-Tool)
