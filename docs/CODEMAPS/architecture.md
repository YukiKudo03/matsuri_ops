<!-- Generated: 2026-03-13 | Files scanned: 180+ | Token estimate: ~800 -->
# Architecture

## Stack
Elixir 1.17 / Phoenix 1.8.5 / LiveView 1.1 / PostgreSQL 16 / Tailwind + daisyUI

## Layer Diagram
```
┌─────────────────────────────────────────────┐
│  Browser (LiveView WebSocket + Long-poll)   │
├─────────────────────────────────────────────┤
│  Router → LiveViews / Controllers           │
│  CoreComponents (button, input, modal, etc) │
├─────────────────────────────────────────────┤
│  Contexts (18 business logic modules)       │
│  Accounts│Festivals│Tasks│Budgets│Chat│...  │
├─────────────────────────────────────────────┤
│  Ecto Schemas (~30 tables)                  │
│  PostgreSQL 16                              │
└─────────────────────────────────────────────┘
```

## Feature Domains (18 contexts)
| Domain | Context | LiveView | Key Tables |
|--------|---------|----------|------------|
| Auth | Accounts | Login, Registration, Settings | users, users_tokens |
| Festivals | Festivals | FestivalLive.Index/Show | festivals, festival_members |
| Tasks | Tasks | TaskLive.Index/Show, GanttLive | tasks, task_categories, checklist_items |
| Budget | Budgets | BudgetLive.Index | budget_categories, expenses, incomes |
| Staff | Festivals | StaffLive.Index | festival_members |
| Shifts | Shifts | ShiftLive.Index | shifts, shift_assignments |
| Operations | Operations | OperationsLive.Dashboard | incidents, area_status |
| Chat | Chat | ChatLive.Index/Room | chat_rooms, messages, read_statuses |
| Documents | Documents | DocumentLive.Index/Show | documents, document_versions |
| Announcements | Notifications | AnnouncementLive.Index | announcements, push_subscriptions |
| Gallery | Gallery | GalleryLive.Index/Show/Moderation | gallery_images |
| QR Codes | QRCodes | QRCodeLive.Index/Show | qr_codes |
| Ad Banners | Advertising | AdBannerLive.Index/Show | ad_banners |
| Social Media | SocialMedia | SocialMediaLive.Index/Show/Accounts | social_accounts, social_posts |
| Locations | Locations | LocationLive.Index | staff_locations |
| Reports | Reports | ReportLive.Index/Compare | (computed from tasks/budgets) |
| Templates | Templates | TemplateLive.Index/Show/Apply | templates |
| Cameras | Cameras | (no LiveView yet) | cameras, camera_recordings |

## Data Flow
```
User → Browser → WebSocket → LiveView.handle_event/3
  → Context.function/N → Ecto.Repo → PostgreSQL
  → Context returns → LiveView.assign/3 → HEEx render → Browser
```

## Real-time: PubSub channels
- Chat: `chat:room:{id}` (new messages)
- Operations: `operations:{festival_id}` (incidents, area updates)
- Announcements: `announcements:{festival_id}`
- Cameras: `cameras:{festival_id}`
- Locations: `locations:{festival_id}`

## Docker Services
| Service | Image | Purpose |
|---------|-------|---------|
| db | postgres:16-alpine | Database |
| app | Dockerfile.dev (elixir:1.17-slim) | Dev server :4000 |
| test | Dockerfile.test (elixir:1.17-slim + Chrome) | E2E tests |
