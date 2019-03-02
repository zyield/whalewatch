defmodule WhalewatchApp.TransactionsTest do
  use WhalewatchApp.DataCase

  alias WhalewatchApp.Transactions

  import WhalewatchApp.Factory

  describe "transactions" do
    test "create_transaction/1 creates a transaction with valid attributes" do
      block = insert(:block, number: 23454)

      attrs = %{
        hash: "0x434",
        contract_address: "0x88758",
        from: "0x6654563",
        to: "0x5435534",
        block_id: block.id
      }
      transaction = Transactions.create_transaction(attrs)

			assert transaction.contract_address == "0x88758"
		end

    test "create_btc_transaction/1 creates a btc transaction with valid attributes" do
      attrs = %{
        hash: "0x434",
        from: "0x6654563",
        to: "0x5435534",
        value: 0
      }
      transaction = Transactions.create_btc_transaction(attrs)

			assert transaction.hash == "0x434"
			assert Transactions.list_btc_transactions |> length == 1
		end
	end
end
