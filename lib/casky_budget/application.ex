defmodule CaskyBudget.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CaskyBudgetWeb.Telemetry,
      CaskyBudget.Repo,
      {DNSCluster, query: Application.get_env(:casky_budget, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CaskyBudget.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: CaskyBudget.Finch},
      # Start a worker by calling: CaskyBudget.Worker.start_link(arg)
      # {CaskyBudget.Worker, arg},
      # Start to serve requests, typically the last entry
      CaskyBudgetWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CaskyBudget.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CaskyBudgetWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
