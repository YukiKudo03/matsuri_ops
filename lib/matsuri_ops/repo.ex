defmodule MatsuriOps.Repo do
  use Ecto.Repo,
    otp_app: :matsuri_ops,
    adapter: Ecto.Adapters.Postgres
end
