{:ok, _} = Application.ensure_all_started(:wallaby)
Application.put_env(:wallaby, :base_url, MatsuriOpsWeb.Endpoint.url())

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(MatsuriOps.Repo, :manual)
