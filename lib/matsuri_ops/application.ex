defmodule MatsuriOps.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MatsuriOpsWeb.Telemetry,
      MatsuriOps.Repo,
      {DNSCluster, query: Application.get_env(:matsuri_ops, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: MatsuriOps.PubSub},
      # Start a worker by calling: MatsuriOps.Worker.start_link(arg)
      # {MatsuriOps.Worker, arg},
      # Start to serve requests, typically the last entry
      MatsuriOpsWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MatsuriOps.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MatsuriOpsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
