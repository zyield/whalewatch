defmodule WhalewatchApp.TokensTest do
  use WhalewatchApp.DataCase

  import WhalewatchApp.Factory

  alias WhalewatchApp.Tokens

	setup do
    insert(:token, symbol: "ETH", contract_address: nil, name: "Ethereum", price: 20000)
    token = insert(:token, symbol: "CMCT", contract_address: "0x123", name: "Crowd Machine")

		%{ token: token }
	end

	describe "tokens" do
    test "get_by_symbol/1 returns the token given a symbol", %{ token: token } do
			assert Tokens.get_by_symbol("CMCT") == {:ok, token }
		end

    test "get_by_address/1 returns the token given a contract_address" do
			token = Tokens.get_by_address("0x123")

      assert token.contract_address == "0x123"
		end

    test "get_eth/0 returns ethereum record" do
			token = Tokens.get_eth()

      assert token.name == "Ethereum"
		end

    test "eth_price/0 returns price in dollard" do
			price = Tokens.eth_price()

      assert price == 200
		end
	end
end
