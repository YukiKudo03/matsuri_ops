# Wallabyは環境によって利用できない場合があるため、条件付きで起動
case Application.ensure_all_started(:wallaby) do
  {:ok, _} ->
    Application.put_env(:wallaby, :base_url, MatsuriOpsWeb.Endpoint.url())
  {:error, _} ->
    # Wallabyが利用できない場合はスキップ（Docker環境など）
    :ok
end

ExUnit.start(exclude: [:feature])
Ecto.Adapters.SQL.Sandbox.mode(MatsuriOps.Repo, :manual)
