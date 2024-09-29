defmodule Ankra.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AnkraWeb.Telemetry,
      Ankra.Repo,
      {DNSCluster, query: Application.get_env(:ankra, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Ankra.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Ankra.Finch},
      {AshAuthentication.Supervisor, otp_app: :ankra},
      # Start a worker by calling: Ankra.Worker.start_link(arg)
      # {Ankra.Worker, arg},
      # Start to serve requests, typically the last entry
      AnkraWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ankra.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AnkraWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
