<!-- Generated: 2026-03-13 | Files scanned: mix.exs, config/ | Token estimate: ~500 -->
# Dependencies

## Runtime Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| phoenix | ~1.8.5 | Web framework |
| phoenix_live_view | ~1.1.0 | Real-time UIs via WebSocket |
| phoenix_ecto | ~4.5 | Ecto integration layer |
| ecto_sql | ~3.13 | SQL/PostgreSQL ORM |
| postgrex | >=0.0.0 | PostgreSQL driver |
| bandit | ~1.5 | HTTP server |
| bcrypt_elixir | ~3.0 | Password hashing |
| swoosh | ~1.17 | Email delivery |
| finch | ~0.19 | HTTP client (Swoosh adapter) |
| gettext | ~1.0 | i18n (ja, vi) |
| jason | ~1.2 | JSON encoding/decoding |
| qr_code | ~3.1 | QR code SVG/PNG generation |
| dns_cluster | ~0.2.0 | DNS-based clustering |
| telemetry_metrics | ~1.0 | Metrics collection |
| telemetry_poller | ~1.0 | Telemetry polling |

## Dev-only Dependencies
| Package | Purpose |
|---------|---------|
| phoenix_live_reload | Hot reload |
| esbuild | JS bundling |
| tailwind | CSS compilation |
| heroicons (v2.2.0) | SVG icon library |

## Test-only Dependencies
| Package | Purpose |
|---------|---------|
| lazy_html | HTML assertion helpers |
| wallaby (~0.30) | Browser automation (E2E) |

## External Services
| Service | Usage | Config |
|---------|-------|--------|
| PostgreSQL 16 | Primary datastore | DATABASE_URL (prod), localhost (dev) |
| Swoosh.Adapters.Local | Email (dev) | Mailbox at /dev/mailbox |
| Chrome/ChromeDriver | E2E testing | Dockerfile.test |

## No external API integrations
- Email: local adapter only (no SMTP/SendGrid configured)
- Social media: schema-only (no API keys/OAuth configured)
- Cameras: schema-only (no streaming service connected)
- Push notifications: schema-only (no FCM/APNS configured)
