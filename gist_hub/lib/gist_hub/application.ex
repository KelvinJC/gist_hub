defmodule GistHub.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GistHubWeb.Telemetry,
      GistHub.Repo,
      {DNSCluster, query: Application.get_env(:gist_hub, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: GistHub.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: GistHub.Finch},
      # Start a worker by calling: GistHub.Worker.start_link(arg)
      # {GistHub.Worker, arg},
      # Start to serve requests, typically the last entry
      GistHubWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GistHub.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GistHubWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
