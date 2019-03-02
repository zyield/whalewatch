defmodule WhalewatchApp.AlertFilterTest do
  use WhalewatchApp.DataCase, async: true

  import Mox
  import WhalewatchApp.Factory

  alias WhalewatchApp.AlertsMock
  alias WhalewatchApp.Notifications.AlertFilter

  setup do
    eth_tx = %{
      block_id: 2022,
      cents_value: 482520000,
      decimals: 18,
      from: "0x3f5ce5fbfe3e9af3971dd833d26ba9b5c936f0be",
      from_name: "Unknown wallet",
      hash: "0x846c342793f8c7ddb2c2cb13f465cb1d11de12d41735971845b5ab6fc8a91c02",
      is_token_tx: false,
      price: 20000,
      to: "0x0681d8db095565fe8a346fa0277bffde9c0edbbf",
      to_name: "Unknown wallet",
      token_amount: "24126",
      value: "0x51bdf8236f942380000"
    }

    token_tx = %{
      block_id: 2032,
      cents_value: 172500000,
      contract_address: "0xd26114cd6ee289accf82350c8d8487fedb8a0c07",
      decimals: 18,
      from: "0xd007058e9b58e74c33c6bf6fbcd38baab813cbb6",
      from_name: "Unknown wallet",
      hash: "0xa86a5857260093e6b262feb450b7ae5a1999cf7d476229ac5992dd4bf7b42553",
      is_token_tx: true,
      price: 345,
      symbol: "OMG",
      to: "0xa04248bbbdae26fadc85e55ef79ec17ace948370",
      to_name: "Unknown wallet",
      token_amount: "500000",
      value: "0x0000000000000000000000000000000000000000000069e10de76676d0800000"
    }

    btc_tx = %{
      from: "123123123z",
      from_name: nil,
      to: "123123123x",
      to_name: nil,
      hash: "000",
      block_id: nil,
      is_btc_tx: true,
      value: '1111199231',
      token_amount: 200.5,
      cents_value: 500_000_00
    }

    %{token_tx: token_tx, eth_tx: eth_tx, btc_tx: btc_tx}
  end

  describe "notificator" do
    test "eth_message/2 returns correct message", %{ eth_tx: eth_tx } do
      AlertsMock
      |> expect(:list_eth_alerts, fn (_value, _from, _to) ->
        [%{user: %{ email: "test@test.com"}}]
      end)

      insert(:user, email: "john.doe@coinbase.com")
      alert = insert(:alert, threshold: 10_000_00, symbol: nil, contract_address: nil)
      message = AlertFilter.eth_message(alert, eth_tx)

      assert message.email  == "john.doe@example.com"
      assert message.symbol == "ETH"
      assert message.from   == { "Unknown wallet" , "0x3f5ce5fbfe3e9af3971dd833d26ba9b5c936f0be" }
      assert message.to     == { "Unknown wallet" , "0x0681d8db095565fe8a346fa0277bffde9c0edbbf" }
      assert message.token_amount == "24126"
      assert message.cents_value == 482520000
    end

    test "token_message/2 for token_tx", %{ token_tx: token_tx } do
      insert(:wallet, name: "binance", address: "0xfe9e8709d3215310075d67e3ed32a380ccf451c8")
      insert(:token, contract_address: "0xd26114cd6EE289AccF82350c8d8487fedB8A0C07", symbol: "OMG", price: 347, decimals: 18)
      insert(:user, email: "john.doe@coinbase.com")
      alert = insert(:alert, threshold: 10_000_00, symbol: nil, contract_address: nil)

      AlertsMock
      |> expect(:list_eth_alerts, fn (_value, _from, _to) ->
        [%{user: %{ email: "test@test.com"}}]
      end)

      message = AlertFilter.token_message(alert, token_tx)

      assert message.symbol == "OMG"
    end

    test "btc_message/2 for token_tx", %{btc_tx: btc_tx} do
      insert(:token, contract_address: nil, symbol: "BTC", price: 6500_00, decimals: 8)
      insert(:user, email: "john.doe@coinbase.com")
      alert = insert(:alert, threshold: 10_000_00, symbol: "BTC", contract_address: nil)

      AlertsMock
      |> expect(:list_btc_alerts, fn (_value, _from, _to) ->
        [%{user: %{ email: "test@test.com"}}]
      end)

      message = AlertFilter.btc_message(alert, btc_tx)

      assert message.symbol == "BTC"
    end
  end
end
