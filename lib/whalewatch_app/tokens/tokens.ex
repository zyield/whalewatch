defmodule WhalewatchApp.Tokens do
  import Ecto.{Query, Changeset}, warn: false
  alias WhalewatchApp.Tokens.Token
  alias WhalewatchApp.Repo

  def list_tokens do
    from(token in Token,
      order_by: [asc: :symbol]
    )
    |> Repo.all
  end

  def get_by_address(address) do
     Token
     |> Repo.get_by(contract_address: address)
     |> format_price
  end

  def get_by_symbol(symbol) do
    case Repo.get_by(Token, symbol: symbol) do
      nil -> {:error, nil }
      token -> {:ok,  token}
    end
  end

  def token_price(address) do
    case get_by_address(address) do
      %Token{price: price} -> price |> to_dollars
      _ -> nil
    end
  end

  def get_btc, do: get_by_symbol("BTC")

  def get_eth, do: Token |> Repo.get_by(name: "Ethereum")

  def eth_price, do: get_eth() |> Map.get(:price) |> to_dollars

  def update_price(%{id: id, price: price}) do
    record = Repo.get(Token, id)
             |>  Ecto.Changeset.change(price: price)

    case Repo.update record do
      {:ok, _struct } -> IO.puts "Successful"
      {:error, _changeset } -> IO.puts "Error"
    end
  end

  @doc """
  Creates or updates a token

  ## Examples

      iex> create_token(%{field: value})
      {:ok, %Token{}}

      iex> create_token(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_token(attrs = %{name: _name, symbol: _symbol, type: _type, decimals: _decimals }) do
    Token.changeset(%Token{}, attrs)
     |> Repo.insert(
        on_conflict: :replace_all,
        conflict_target: [:symbol])
  end

  defp format_price(token = %Token{price: price}) do
    token |> Kernel.struct(price: price |> to_dollars)
  end
  defp format_price(token) when is_nil(token), do: nil

  defp to_dollars(cents) when is_nil(cents), do: nil
  defp to_dollars(cents), do: cents / 100
end
