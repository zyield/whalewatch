defmodule WhalewatchApp.BtcWatcherTest do
  use WhalewatchApp.DataCase, async: true

  import Mox
  import WhalewatchApp.Factory
  alias WhalewatchApp.AlertsMock
  alias WhalewatchApp.NotificationMessageMock
  alias WhalewatchApp.AlertFilterMock
  alias WhalewatchApp.Watchers.BtcWatcher
  alias WhalewatchApp.Transactions

  describe "BTC watcher" do
    setup do
      AlertFilterMock
      |> expect(:process_transaction, fn (_transaction) -> nil end)

      NotificationMessageMock
      |> expect(:notification, fn (_message) ->
        :ok
      end)

      AlertsMock
      |> expect(:list_btc_alerts, fn (_value, _from, _to) ->
        [%{user: %{ email: "test@test.com"}}]
      end)
      |> expect(:list_token_alerts, fn (_value, _from, _to, _contract_address) ->
        [%{user: %{ email: "test@test.com"}}]
      end)

      insert(:token, symbol: "BTC", name: "Bitcoin", decimals: 8, price: 6500_00)

      with {:ok, tx_fixture } <- File.read("test/fixtures/btc_tx.json"),
           {:ok, small_tx_fixture } <- File.read("test/fixtures/btc_tx_below_thresh.json"),
           {:ok, tx} <- Poison.decode(tx_fixture),
           {:ok, small_tx} <- Poison.decode(small_tx_fixture)
      do
        %{btc_tx: tx, small_btc_tx: small_tx}
      end

    end

    test "process_tx/1 saves the btc transaction if amount above 50 BTC and money value > 500k ", %{btc_tx: tx} do
      tx
      |> BtcWatcher.process_tx

      assert length(Transactions.list_btc_transactions) == 1
    end
    test "process_tx/1 doesn't save the btc transaction if value below 50 BTC", %{small_btc_tx: tx} do
      tx
      |> BtcWatcher.process_tx

      assert length(Transactions.list_btc_transactions) == 0
    end
    test "process_tx/1 returns the tx data with correct params", %{btc_tx: tx} do
      insert(:wallet, name: "Coinberry", type: :btc, address: "1ADjKWiwKLXfD1fjoeLhuC7qPPnU4te9Wm")

      processed_tx = tx |> BtcWatcher.process_tx

      assert processed_tx.from == "1ADjKWiwKLXfD1fjoeLhuC7qPPnU4te9Wm"
      assert processed_tx.from_name == "Coinberry"
      assert processed_tx.to == "1JRf44khKEmYNboh5BVzjkV5nBqk6Km6D3"
      assert processed_tx.to_name == "Unknown wallet"
      assert processed_tx.hash == "8164c56833d124866643024b5876627daed96ddb2a947024b5b6451a53c6ee22"
      assert processed_tx.is_btc_tx == true
      assert processed_tx.value == 15000000000
      assert processed_tx.token_amount == 150
      assert processed_tx.cents_value == 97500000
    end
  end
end
