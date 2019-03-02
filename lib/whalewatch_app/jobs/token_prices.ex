defmodule WhalewatchApp.Jobs.TokenPrices do
  use GenServer

  alias WhalewatchApp.Tokens

  @currency "USD"

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_next_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    work()
    schedule_next_work()
    {:noreply, state}
  end

  def work do
    Tokens.list_tokens
      |> Enum.map(&get_price/1)
      |> Enum.each(&Tokens.update_price/1)
  end

  def get_price(token) do
    IO.puts "Getting price for #{token.name}..."
    Process.sleep(1000) # timeout to work around CryptoCompare API limits
    price = price_for(token.symbol, @currency)

    %{id: token.id, price: price}
  end

  def price_for(symbol, currency) do
    with {:ok, data } <- CryptoCompare.price(symbol, currency) do
      data
      |> Map.get(currency |> String.to_atom)
      |> to_cents
    else
      _ -> nil
    end
  end

  defp schedule_next_work do
    Process.send_after(self(), :work, 24 * 60 * 60 * 1000)
  end

  defp to_cents(nil), do: 0
  defp to_cents(price), do: 100 * price |> Kernel.trunc
end
