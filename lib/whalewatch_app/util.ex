defmodule WhalewatchApp.Util do
  alias WhalewatchApp.Wallets

  def to_int(nil), do: 0
  def to_int(0), do: 0
  def to_int(%Decimal{} = value), do: round_and_convert(value)
  def to_int(decimal) when is_integer(decimal), do: decimal
  def to_int(decimal) when is_float(decimal) do
    decimal
    |> Decimal.from_float
    |> round_and_convert
  end

  defp round_and_convert(%Decimal{} = decimal) do
    decimal
    |> Decimal.round
    |> Decimal.to_integer
  end

  def parse_value(0),    do: 0
  def parse_value("0x"), do: 0
  def parse_value(nil), do: 0
  def parse_value(value) do
    {v, _} = value |> String.slice(2..-1) |> Integer.parse(16)
    v
  end

  def to_token(nil, nil), do: 0
  def to_token(0, _decimals),    do: 0
  def to_token(value, decimals), do: value * :math.pow(10, -decimals) |> to_rounded

  def to_rounded(float, decimals \\ 2)
  def to_rounded(0, _decimals), do: 0
  def to_rounded(nil, _decimals), do: 0
  def to_rounded(%Decimal{} = float, decimals) do
    float
    |> Decimal.round(decimals)
  end
  def to_rounded(float, decimals) do
    float
    |> Decimal.from_float
    |> Decimal.round(decimals)
  end

  def is_eth?(nil), do: false
  def is_eth?(%{} = token), do: token.name == "Ethereum"
  def is_eth?(_), do: false

  def to_cents_value(value, price) when is_nil(value) or is_nil(price), do: 0
  def to_cents_value(0, 0), do: 0
  def to_cents_value(%Decimal{} = value, price), do: Decimal.mult(value, price) |> to_int
  def to_cents_value(value, price), do: (value * price) |> Kernel.trunc

  def format_value(0),    do: 0
  def format_value(nil),  do: 0
  def format_value("0x"), do: 0
  def format_value(value, decimals) do
    value |> parse_value |> to_token(decimals)
  end

  def process_wallet_name(wallet_address) do
    with {:ok, wallet } <- Wallets.get_by_address(wallet_address) do
      wallet.name
      |> String.capitalize
    else
      _ ->
        "Unknown wallet"
    end
  end
end
