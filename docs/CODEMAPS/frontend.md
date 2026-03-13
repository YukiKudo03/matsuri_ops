<!-- Generated: 2026-03-13 | Files scanned: 40+ | Token estimate: ~700 -->
# Frontend

## Component Hierarchy
```
Layouts.root (HTML shell, meta, CSRF)
└── Layouts.app (navbar, theme toggle, flash_group)
    └── LiveView module (mount/handle_event/render)
        ├── CoreComponents.header (title, subtitle, actions)
        ├── CoreComponents.table (zebra rows, row_click, actions)
        ├── CoreComponents.modal (escape close, animations)
        │   └── *FormComponent (simple_form, inputs, submit)
        ├── CoreComponents.simple_form (for, change, submit)
        │   ├── CoreComponents.input (text/email/select/textarea/checkbox)
        │   └── CoreComponents.button (primary/outline/success/danger)
        ├── CoreComponents.list (title/content pairs)
        ├── CoreComponents.back (← navigate)
        └── CoreComponents.flash (info/error toasts)
```

## Design System
- **Framework**: Tailwind CSS v4.1 + daisyUI
- **Icons**: Heroicons v2.2.0
- **Design Language**: Sakurai Game Design + Apple HIG
- **Color Space**: OKLCH
- **Themes**: Light (warm off-white) / Dark (deep navy)

## Key Design Tokens
```
Touch target:   44px min (Apple HIG)
Border radius:  8px buttons, 12px friendly, 16px cards
Timing:         60ms instant, 150ms quick, 300ms normal
Easing:         cubic-bezier(0.2, 0, 0, 1) responsive
```

## JS (assets/js/app.js)
- LiveSocket with CSRF params, long-poll fallback (2500ms)
- Colocated hooks from `phoenix-colocated/matsuri_ops`
- topbar progress indicator on page-loading events
- Dev: server log streaming, component source click helpers

## Animations
- `slideInRight` - notifications
- `slideInUp` - elements
- `successPulse` - green glow feedback
- `gentleBounce` - subtle motion
- All disabled via `prefers-reduced-motion`

## i18n
- Default locale: `ja` (Japanese)
- Supported: Japanese, Vietnamese
- Via Gettext (`lib/matsuri_ops_web/gettext.ex`)
