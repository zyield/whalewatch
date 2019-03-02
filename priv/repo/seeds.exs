# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# It is also run when you use the command `mix ecto.setup`
#

alias WhalewatchApp.Tokens
alias WhalewatchApp.Tokens.Token
alias WhalewatchApp.Wallets.Wallet
alias WhalewatchApp.Repo

defmodule RemoteCSV do
  def stream(path) do
    Stream.resource(fn -> start_stream(path) end,
                                       &continue_stream/1,
                                       fn(_) -> :ok end)
  end

  defp start_stream(path) do
    {:ok, _status, _headers, ref} = :hackney.get(path, [], "")

    {ref, ""}
  end

  defp continue_stream(:halt), do: {:halt, []}
  defp continue_stream({ref, partial_row}) do
    case :hackney.stream_body(ref) do
      {:ok, data} ->
        data = partial_row <> data

        if ends_with_line_break?(data) do
          rows = split(data)

          {rows, {ref, ""}}
        else
          {rows, partial_row} = extract_partial_row(data)

          {rows, {ref, partial_row}}
        end

      :done ->
        if partial_row == "" do
          {:halt, []}
        else
          {[partial_row], :halt}
        end

      {:error, reason} ->
        raise reason
    end
  end

  defp extract_partial_row(data) do
    data = split(data)
    rows = Enum.drop(data, -1)
    partial = List.last(data)

    {rows, partial}
  end

  defp split(data), do: String.split(data, ~r/(\r?\n|\r)/, trim: true)

  defp ends_with_line_break?(data), do: String.match?(data, ~r/(\r?\n|\r)$/)
end

defmodule WhalewatchApp.Seeds do
  def store_token(row) do
    {decimals, ""} = Integer.parse(row[:decimals])
    changeset = Token.changeset(%Token{}, %{
      name: row[:name] |> String.trim,
      type: :erc20,
      symbol: row[:symbol] |> String.trim,
      contract_address: row[:contract_address] |> String.downcase,
      decimals: decimals,
      price: nil
    }) |> Repo.insert_or_update
  end

  def store_wallet(row = %{name: name}, :erc20) when name !== "" do
    Wallet.changeset(%Wallet{}, %{
      name: name |> format_name,
      address: row[:address],
      type: :eth
    }) |> Repo.insert_or_update
  end

  def store_wallet(row = %{name: name}, :btc) when name !== "" do
    name = case Regex.scan(~r/wallet:\s([A-Za-z].*)-?.*/, name) do
      [] -> :ok
      [[_, name]] ->
        Wallet.changeset(%Wallet{}, %{
          name: name,
          address: row[:address],
          type: :btc
        }) |> Repo.insert_or_update
    end
  end

  def store_wallet(_, _), do: nil

  defp format_name(name), do: name |> String.downcase |> String.split("_") |> Enum.at(0)

end

tokens_url = "https://s3.ca-central-1.amazonaws.com/whalewatch-seeds/tokens.csv"

RemoteCSV.stream(tokens_url)
  |> CSV.decode(headers: [:name, :symbol, :contract_address, :decimals])
  |> Enum.each(&WhalewatchApp.Seeds.store_token/1)

RemoteCSV.stream("https://s3.ca-central-1.amazonaws.com/sqrly-uploads/EthScan+Top+10k+-+Sheet1.csv")
  |> CSV.decode(headers: [:rank, :_, :address, :name ])
  |> Enum.each(&WhalewatchApp.Seeds.store_wallet(&1, :erc20))

RemoteCSV.stream("https://s3.ca-central-1.amazonaws.com/whalewatch-seeds/btc_wallets.csv")
  |> CSV.decode(headers: [:address, :name])
  |> Enum.each(&WhalewatchApp.Seeds.store_wallet(&1, :btc))

RemoteCSV.stream("https://s3.ca-central-1.amazonaws.com/whalewatch-seeds/wallets.csv")
  |> CSV.decode(headers: [:address, :name])
  |> Enum.each(&WhalewatchApp.Seeds.store_wallet(&1, :erc20))

[
  %{name: "Ethereum", symbol: "ETH", type: :eth, decimals: 18, price: 20000},
  %{name: "Bitcoin", symbol: "BTC", type: :btc, decimals: 8, price: 600000}
]
|> Enum.each(&Tokens.create_token/1)
