<!-- Generated: 2026-03-13 | Files scanned: 18 migrations, 30+ schemas | Token estimate: ~950 -->
# Data Layer

## Entity Relationship Diagram
```
USERS ──┬── FESTIVALS (organizer_id)
        │   ├── FESTIVAL_MEMBERS (user_id, role)
        │   ├── TASK_CATEGORIES → TASKS (tree: parent_id)
        │   │                     ├── TASK_DEPENDENCIES
        │   │                     └── CHECKLIST_ITEMS
        │   ├── BUDGET_CATEGORIES → EXPENSES (status workflow)
        │   │                    → INCOMES
        │   ├── INCIDENTS (severity, status workflow)
        │   ├── AREA_STATUS (crowd_level, weather)
        │   ├── CHAT_ROOMS → MESSAGES → READ_STATUSES
        │   ├── SHIFTS → SHIFT_ASSIGNMENTS
        │   ├── DOCUMENTS → DOCUMENT_VERSIONS
        │   ├── ANNOUNCEMENTS
        │   ├── GALLERY_IMAGES (moderation workflow)
        │   ├── QR_CODES
        │   ├── AD_BANNERS → SPONSORS → SPONSORSHIPS → BENEFITS
        │   ├── SOCIAL_ACCOUNTS → SOCIAL_POSTS
        │   ├── CAMERAS → CAMERA_RECORDINGS
        │   └── STAFF_LOCATIONS
        └── USERS_TOKENS (session, magic_link)
            PUSH_SUBSCRIPTIONS
            TEMPLATES
```

## Key Tables

| Table | Key Fields | Indexes |
|-------|-----------|---------|
| users | email (citext, unique), role, hashed_password | email, role |
| festivals | name, scale, status, start/end_date, organizer_id | status, start_date |
| festival_members | festival_id, user_id, role | unique(festival_id, user_id) |
| tasks | title, status, priority, progress_percent, parent_id | festival, category, assignee, status |
| expenses | amount, status, payment_method | festival, category, status |
| incidents | severity, category, status | festival, status, severity |
| messages | content, message_type | chat_room, user, inserted_at |
| gallery_images | status, featured, view/like_count | festival, status, featured |

## Status Workflows

**Festivals**: planning → preparation → active → completed/cancelled
**Tasks**: pending → in_progress → completed/cancelled/blocked
**Expenses**: pending → submitted → approved/rejected → paid
**Incomes**: expected → confirmed → received/cancelled
**Incidents**: reported → acknowledged → in_progress → resolved → closed
**Gallery**: pending → approved/rejected
**Social Posts**: draft → scheduled → posting → posted/failed

## Migration Timeline (18 files)
```
20260307 users, users_tokens
20260307 users (add role, name, phone fields)
20260307 festivals, festival_members
20260307 task_categories, tasks, dependencies, checklists
20260307 budget_categories, expenses, incomes
20260307 incidents, area_status
20260308 templates, chat, locations, documents, announcements
20260308 shifts, cameras, sponsors, qr_codes, ad_banners
20260308 gallery_images, social_accounts, social_posts
```

## Conventions
- All timestamps: `utc_datetime`
- Foreign keys: `on_delete: :delete_all` (children), `:nilify_all` (optional refs)
- Sponsors: `on_delete: :restrict` (prevent deletion with active sponsorships)
- Pool: `Ecto.Adapters.SQL.Sandbox` (test), `DBConnection.ConnectionPool` (dev/prod)
