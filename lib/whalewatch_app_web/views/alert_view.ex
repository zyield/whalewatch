defmodule WhalewatchAppWeb.AlertView do
  use WhalewatchAppWeb, :view
  alias WhalewatchApp.Tokens
  alias WhalewatchApp.Wallets
  alias WhalewatchApp.Repo
  alias WhalewatchApp.Accounts

  def has_more_than_one_alert(user) do
    Accounts.alert_count(user.id) > 1
  end

  def hide_symbol(:erc20), do: false
  def hide_symbol(_type), do: true

  def hide_exchanges(:btc), do: true
  def hide_exchanges(_type), do: false

  def active_token(current_type, type) when current_type == type, do: true
  def active_token(_,_), do: false

  def tokens() do
    Tokens.list_tokens
    |> Enum.filter(fn %{symbol: symbol} -> symbol != "ETH" and symbol != "BTC" end)
    |> Enum.map(fn token -> {"#{token.symbol} (#{token.name})", token.symbol} end)
  end

  def exchanges(type \\ :eth) do
    type = case type do
      :btc -> :btc
      "btc" -> :btc
      _ -> :eth
    end

    Wallets.list_wallets(type)
    |> Enum.map(fn wallet ->
      %{ name: wallet.name |> String.capitalize, value: wallet.name }
    end)
  end

  def exchange_name(alert) do
    alert.wallets
    |> first_wallet
    |> name_or_blank
  end

  def symbol(alert) do
    case alert.symbol do
      nil -> "ETH"
      _ -> alert.symbol
    end
  end

  defp first_wallet(wallets) do
    List.first(wallets)
  end
  defp name_or_blank(nil) do
    ""
  end
  defp name_or_blank(wallet) do
    wallet.name
    |> String.capitalize
  end

  def full_errors(changeset) do
    for {key, {message, _}} <- changeset.errors do
      "#{key |> Atom.to_string |> String.capitalize} #{message}. "
    end
  end
end
