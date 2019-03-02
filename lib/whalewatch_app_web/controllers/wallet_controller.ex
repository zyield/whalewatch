defmodule WhalewatchAppWeb.WalletController do
  use WhalewatchAppWeb, :controller

  alias WhalewatchApp.Wallets

  def index(conn, %{ "type" => type }) do
    wallets = Wallets.list_wallets(type)
    render(conn, "index.json", %{ wallets: wallets })
  end
end
