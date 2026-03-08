import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :matsuri_ops, MatsuriOps.Repo,
  username: "postgres",
  password: "postgres",
  hostname: System.get_env("DATABASE_HOST", "localhost"),
  database: "matsuri_ops_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# Run a server during test for Wallaby E2E tests
config :matsuri_ops, MatsuriOpsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "EvqfUWpiGnjIOVWGzezfEEVsUVlAnNw1lRHK7igYE+PddYWV1ae1Ngof7KFCvjry",
  server: true

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Sort query params output of verified routes for robust url comparisons
config :phoenix,
  sort_verified_routes_query_params: true

# Wallaby E2E test configuration
config :wallaby,
  driver: Wallaby.Chrome,
  chromedriver: [
    path: System.get_env("HOME") <> "/.local/bin/chromedriver",
    headless: true
  ],
  screenshot_on_failure: true,
  screenshot_dir: "tmp/wallaby_screenshots"
