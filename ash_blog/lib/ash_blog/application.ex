defmodule AshBlog.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AshBlogWeb.Telemetry,
      AshBlog.Repo,
      {DNSCluster, query: Application.get_env(:ash_blog, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: AshBlog.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: AshBlog.Finch},
      # Start a worker by calling: AshBlog.Worker.start_link(arg)
      # {AshBlog.Worker, arg},
      # Start to serve requests, typically the last entry
      AshBlogWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AshBlog.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AshBlogWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
