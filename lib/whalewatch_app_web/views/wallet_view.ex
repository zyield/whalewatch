defmodule WhalewatchAppWeb.WalletView do
  use WhalewatchAppWeb, :view

  alias WhalewatchAppWeb.WalletView

  def render("index.json", %{ wallets: wallets }) do
    render_many(wallets, WalletView, "wallet.json")
  end

  def render("wallet.json", %{ wallet: wallet }) do
    %{
      name: wallet.name |> String.capitalize,
      value: wallet.name
    }
  end
end
