defmodule WhalewatchAppWeb.TransactionView do
  use WhalewatchAppWeb, :view
  import Scrivener.HTML

  def formatted_date(date) do
    Timex.format!(date, "%Y-%m-%d %H:%M", :strftime)
  end

  def details_link(notification) do
    case notification.symbol do
      "BTC" ->
        "https://www.blockchain.com/btc/tx/#{notification.hash}"
      _ ->
        "https://etherscan.io/tx/#{notification.hash}"
    end
  end
end
