defmodule WhalewatchApp.Notifications.Message do
  import Bamboo.Email
  alias WhalewatchApp.Mailer

  @callback notification(map) :: any

  @base_url Application.get_env(:whalewatch_app, :base_url)
  @etherscan_address_url "https://etherscan.io/address/"
  @etherscan_tx_url "https://etherscan.io/tx/"

  @blockchain_address_url "https://www.blockchain.com/btc/address/"
  @blockchain_tx_url "https://www.blockchain.com/btc/tx/"

  def notification(%{ email: email, token_amount: token_amount, symbol: symbol, cents_value: cents_value, from: from , to: to, hash: hash}) do
    message_body = body(token_amount, symbol, cents_value, from, to, hash)

    prep_mail(email)
    |> subject("#{symbol} Alert: #{token_amount} #{symbol} transaction")
    |> html_body(message_body)
    |> Mailer.deliver_now()

    message_body
  end

  def body(amount, "BTC", cents_value, {from_name, from_address}, {to_name, to_address}, tx_hash) do
    "#{amount} BTC (#{Number.Currency.number_to_currency(cents_value / 100.0)} USD) "
    <> "<a href=\"#{@blockchain_tx_url}#{tx_hash}\">transferred</a> from "
    <> "<a href=\"#{@blockchain_address_url}#{from_address}\">#{from_name}</a> to "
    <> "<a href=\"#{@blockchain_address_url}#{to_address}\">#{to_name}</a>"
    <> "<br/><br/><br/>"
    <> "<p>To modify or cancel this alert please <a href=\"#{@base_url}/login\">Login</a> "
    <> "into your WhaleWatch.io account.<br/>"
    <> "<a href=\"https://whalewatch.typeform.com/to/PgOuxg\">"
    <> "We need your feedback!</a> It will only take 2 minutes of your time, we promise 🤓 </p>"
  end
  def body(amount, symbol, cents_value, {from_name, from_address}, {to_name, to_address}, tx_hash) do
    "#{amount |> Number.Delimit.number_to_delimited} #{symbol} (#{Number.Currency.number_to_currency(cents_value / 100.0)} USD) "
    <> "<a href=\"#{@etherscan_tx_url}#{tx_hash}\">transferred</a> from "
    <> "<a href=\"#{@etherscan_address_url}#{from_address}\">#{from_name}</a> to "
    <> "<a href=\"#{@etherscan_address_url}#{to_address}\">#{to_name}</a>"
    <> "<br/><br/><br/>"
    <> "<p>To modify or cancel this alert please <a href=\"#{@base_url}/login\">Login</a> "
    <> "into your WhaleWatch.io account.<br/>"
    <> "<a href=\"https://whalewatch.typeform.com/to/PgOuxg\">"
    <> "We need your feedback!</a> It will only take 2 minutes of your time, we promise 🤓 </p>"
  end

  defp prep_mail(email) do
    new_email()
    |> to(email)
    |> from({"WhaleWatch.io", "no-reply@whalewatch.io"})
  end
end
