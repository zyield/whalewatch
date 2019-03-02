defmodule WhalewatchApp.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(WhalewatchApp.Repo, []),
      # Start the endpoint when the application starts
      supervisor(WhalewatchAppWeb.Endpoint, [])
      # Start your own worker by calling: WhalewatchApp.Worker.start_link(arg1, arg2, arg3)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WhalewatchApp.Supervisor]

    {:ok, pid} = Supervisor.start_link(children, opts)

    if websocket_watchers_enabled?(), do:
      Supervisor.start_link([worker(WhalewatchApp.Watchers.WsContainer, [])],
        strategy: :one_for_one,
        name: WhalewatchApp.WebsocketSupervisor
      )

    if prices_job_enabled?(), do:
      Supervisor.start_link([worker(WhalewatchApp.Jobs.TokenPrices, [])],
        strategy: :one_for_one,
        name: WhalewatchApp.TokenPricesSupervisor
      )

    if eth_watcher_enabled?(), do:
      Supervisor.start_link([worker(WhalewatchApp.Watchers.EthWatcher, [])],
        strategy: :one_for_one,
        name: WhalewatchApp.EthWatcherSupervisor
      )

    {:ok, pid}
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    WhalewatchAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp eth_watcher_enabled?, do: is_enabled?(:enable_eth_watcher)

  defp websocket_watchers_enabled?, do: is_enabled?(:enable_ws_watchers)

  defp prices_job_enabled?, do: is_enabled?(:enable_price_job)

  defp is_enabled?(module), do: Application.get_env(:whalewatch_app, module) |> is_true?

  defp is_true?("true"), do: true
  defp is_true?(true),   do: true
  defp is_true?(_),      do: false
end
