defmodule WhalewatchApp.Watchers.WsContainer do
  use GenServer
  require Logger

  alias WhalewatchApp.Watchers.BtcWatcher

  defp watchers do
    [BtcWatcher]
  end

  def start_link(state \\ %{}) when is_map(state) do
    GenServer.start_link(__MODULE__, state |> Map.put(:watchers, %{}), [])
  end

  def init(state) do
    watcher_pids = watchers() |> connect_all(state)

    new_state = state |> Map.put(:watchers, watcher_pids)
    {:ok, new_state}
  end

  def handle_info({:DOWN, _, :process, pid, _}, state = %{watchers: watchers}) do
    watcher = watchers |> Map.get(pid)
    {:ok, new_watcher_pid} = watcher |> connect_websocket(state)
    watchers = watchers
              |> Map.delete(pid)
              |> Map.put(new_watcher_pid, watcher)

    {:noreply, state |> Map.put(:watchers, watchers)}
  end

  defp connect_all(watchers, state) do
    watchers
    |> Enum.reduce(%{}, fn (watcher, acc) ->
      {:ok, watcher_pid} = connect_websocket(watcher, state)
      acc |> Map.put(watcher_pid, watcher)
    end)
  end

  defp connect_websocket(watcher, state) do
    case watcher.start_link(state) do
      {:ok, pid} ->
        Process.unlink(pid)
        Process.monitor(pid)

        watcher.subscribe(pid)

        {:ok, pid}
      {:error, %WebSockex.ConnError{}} ->
        connect_websocket(watcher, state)
    end
  end

end
