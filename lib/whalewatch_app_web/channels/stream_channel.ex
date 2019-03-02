defmodule WhalewatchAppWeb.StreamChannel do
  use Phoenix.Channel
  require Logger

  def join("stream:transactions", msg, socket) do
    Process.flag(:trap_exit, true)

    {:ok, socket |> assign(:device_id, msg["device_id"])}
  end

  def join("stream:" <> _private_subtopic, _message, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def terminate(reason, _socket) do
    Logger.debug"> leave #{inspect reason}"
    :ok
  end

  def handle_out(status, msg, socket) do
    push socket, status, msg
    {:noreply, socket}
  end

  def send_tx(event, msg) do
    WhalewatchAppWeb.Endpoint.broadcast_from! self(), "stream:transactions", event, msg
  end
end
