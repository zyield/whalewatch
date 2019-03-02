defmodule WhalewatchApp.Watchers.BtcWatcher do
  use WebSockex

  require Logger

  alias WhalewatchApp.Tokens
  alias WhalewatchApp.Transactions
  alias WhalewatchApp.Util

  @notificator Application.get_env(:whalewatch_app, :notificator)

  @btc_ws_url Application.get_env(:whalewatch_app, :btc_ws_url)
  @btc_sub  %{op: "unconfirmed_sub"}
  @btc_threshold 50
  @value_threshold 500_000_00

  def start_link(parent) do
    WebSockex.start_link(@btc_ws_url, __MODULE__, parent)
  end

  def subscribe(pid) do
    {:ok, message} = Poison.encode(@btc_sub)

    WebSockex.send_frame(pid, {:text, message})
  end

  def handle_connect(_frame, parent) do
    Logger.info "BTC Watcher connected"
    {:ok, parent }
  end

  def handle_frame(frame, parent) do
    { _type, msg } = frame

    case Poison.decode(msg) do
      {:ok, data } -> Task.start(fn -> process_tx(data) end)
      {:error, _ } -> Logger.info "Websocket message error"
    end

    {:ok, parent}
  end

  def process_tx(%{"x" => %{"out" => outputs, "inputs" => inputs, "hash" => hash}}) do
    {_in_value, in_address} = inputs
                            |> Enum.map(fn %{"prev_out" => prev_out} -> prev_out end)
                            |> get_max_value
    {out_value, out_address} = outputs |> get_max_value

    btc_value = out_value |> to_btc |> Util.to_int

    # Initial filtering by BTC amount
    unless in_address == out_address or btc_value < @btc_threshold do
      {:ok, %{price: price}} = Tokens.get_btc
      cents_value = to_cents_value(btc_value, price)

      from_name = in_address  |> Util.process_wallet_name
      to_name   = out_address |> Util.process_wallet_name

      # Secondary filtering by BTC money value
      unless cents_value < @value_threshold do
        %{
          from: in_address,
          from_name: from_name,
          to: out_address,
          to_name: to_name,
          symbol: "BTC",
          hash: hash,
          block_id: nil,
          is_btc_tx: true,
          value: out_value,
          token_amount: btc_value,
          cents_value: cents_value
        }
        |> create_and_notify
      end
    end
  end

  def create_and_notify(transaction) do
    Transactions.create_btc_transaction(transaction)
    @notificator.process_transaction(transaction)
    transaction
  end

  defp get_max_value(txs) do
    txs
    |> Enum.reduce({0, 0}, fn %{"addr" => addr, "value" => value}, acc ->
        {prev_value, _prev_address} = acc
        prev_btc_value = prev_value |> to_btc
        btc_value = value |> to_btc

        if btc_value > prev_btc_value,
          do: {value, addr},
        else: acc
      end)
  end

  defp to_cents_value(value, price), do: (value * price) |> Kernel.trunc

  defp to_btc(value), do: value / 100000000
end
