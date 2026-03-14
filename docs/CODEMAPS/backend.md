<!-- Generated: 2026-03-13 | Files scanned: 80+ | Token estimate: ~900 -->
# Backend

## Routes (router.ex)

### Public
```
GET  /                    → PageController.home
GET  /locale/:locale      → LocaleController.switch
POST /users/log-in        → UserSessionController.create
DEL  /users/log-out       → UserSessionController.delete
```

### Auth: Registration/Login (live_session :current_user)
```
LIVE /users/register      → UserLive.Registration
LIVE /users/log-in        → UserLive.Login
LIVE /users/log-in/:token → UserLive.Confirmation
```

### Auth: Authenticated (live_session :require_authenticated_user)
```
LIVE /users/settings                     → UserLive.Settings
LIVE /festivals                          → FestivalLive.Index
LIVE /festivals/:id                      → FestivalLive.Show
LIVE /festivals/:fid/tasks              → TaskLive.Index
LIVE /festivals/:fid/tasks/:id          → TaskLive.Show
LIVE /festivals/:fid/budgets            → BudgetLive.Index
LIVE /festivals/:fid/staff              → StaffLive.Index
LIVE /festivals/:fid/shifts             → ShiftLive.Index
LIVE /festivals/:fid/operations         → OperationsLive.Dashboard
LIVE /festivals/:fid/chat               → ChatLive.Index
LIVE /festivals/:fid/chat/:id           → ChatLive.Room
LIVE /festivals/:fid/documents          → DocumentLive.Index
LIVE /festivals/:fid/announcements      → AnnouncementLive.Index
LIVE /festivals/:fid/gallery            → GalleryLive.Index
LIVE /festivals/:fid/gallery/moderation → GalleryLive.Moderation
LIVE /festivals/:fid/qr-codes          → QRCodeLive.Index
LIVE /festivals/:fid/ad-banners        → AdBannerLive.Index
LIVE /festivals/:fid/social            → SocialMediaLive.Index
LIVE /festivals/:fid/locations         → LocationLive.Index
LIVE /festivals/:fid/gantt             → GanttLive.Index
LIVE /festivals/:fid/reports           → ReportLive.Index
LIVE /reports/compare                   → ReportLive.Compare
LIVE /templates                         → TemplateLive.Index
LIVE /help/*                            → HelpLive.*
```

All CRUD routes follow pattern: `/festivals/:fid/<resource>` + `/new`, `/:id/edit`

## Key Contexts (lib/matsuri_ops/*.ex)

| Context | Functions | Pattern |
|---------|-----------|---------|
| Accounts | 16 | Email auth, magic link, session tokens, sudo mode |
| Festivals | 14 | CRUD + member management (roles, join/leave) |
| Tasks | 24 | Categories, tasks (tree), dependencies, checklists |
| Budgets | 22 | Categories, expenses (approve/reject), incomes, summary |
| Chat | 14 | Rooms (types), messages, read status, PubSub |
| Operations | 16 | Incidents (severity/status), area status, PubSub |
| Gallery | 22 | Images, moderation (approve/reject/feature), analytics |
| SocialMedia | 22 | Accounts, posts (schedule/publish/fail), analytics |
| Templates | 9 | Create from festival, apply to new festival |

## Auth Flow
```
Email → deliver_login_instructions/2 → magic link token
Token → login_user_by_magic_link/1 → session token → cookie
Session → get_user_by_session_token/1 → UserAuth plug → assigns
```

## Middleware Chain (Endpoint → Router)
```
Plug.Static → RequestId → Telemetry → Parsers
→ MethodOverride → Head → Session → Router
→ :browser pipeline: fetch_session → csrf → flash → live_flash
  → root_layout → secure_headers → fetch_current_scope
→ :require_authenticated_user (redirect if no scope)
```
