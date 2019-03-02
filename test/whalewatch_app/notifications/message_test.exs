defmodule WhalewatchApp.MessageTest do
  use WhalewatchApp.DataCase

  alias WhalewatchApp.Notifications.Message

  describe "notification message" do
    test "notification/1 returns message body" do
      assert Message.notification(%{cents_value: 6930000000, email: "razvan@agilealpha.com", from: {"Unknown wallet", "0x00c5e04176d95a286fcce0e68c683ca0bfec8454"}, hash: "0x9c28fb902b5afa00e4623dda2702e50313813833976aecc2a60db2c0143cae82", symbol: "BNB", to: {"Unknown wallet", "0x9c3bcb281da563565b84535798ffaab653b06f05"}, token_amount: "7000000"}) == "7,000,000.00 BNB ($69,300,000.00 USD) "
      <> "<a href=\"https://etherscan.io/tx/0x9c28fb902b5afa00e4623dda2702e50313813833976aecc2a60db2c0143cae82\">transferred</a> "
      <> "from <a href=\"https://etherscan.io/address/0x00c5e04176d95a286fcce0e68c683ca0bfec8454\">Unknown wallet</a> "
      <> "to <a href=\"https://etherscan.io/address/0x9c3bcb281da563565b84535798ffaab653b06f05\">Unknown wallet</a>"
      <> "<br/><br/><br/>"
      <> "<p>To modify or cancel this alert please <a href=\"http://www.example.com/login\">Login</a> into your WhaleWatch.io account.<br/>"
      <> "<a href=\"https://whalewatch.typeform.com/to/PgOuxg\">We need your feedback!</a> It will only take 2 minutes of your time, we promise 🤓 </p>"
    end

    test "body/5 returns the correct body text" do
      assert Message.body(
        500.0003, "ETH", 10000002.00, {"Unknown wallet", "0x123"}, {"Binance", "0x345"}, "0x75545"
      ) == "500.00 ETH ($100,000.02 USD) "
      <> "<a href=\"https://etherscan.io/tx/0x75545\">transferred</a> "
      <> "from <a href=\"https://etherscan.io/address/0x123\">Unknown wallet</a> "
      <> "to <a href=\"https://etherscan.io/address/0x345\">Binance</a>"
      <> "<br/><br/><br/>"
      <> "<p>To modify or cancel this alert please <a href=\"http://www.example.com/login\">Login</a> into your WhaleWatch.io account.<br/>"
      <> "<a href=\"https://whalewatch.typeform.com/to/PgOuxg\">We need your feedback!</a> It will only take 2 minutes of your time, we promise 🤓 </p>"
    end
  end
end
