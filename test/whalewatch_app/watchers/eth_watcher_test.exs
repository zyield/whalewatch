defmodule WhalewatchApp.EthWatcherTest do
  use WhalewatchApp.DataCase, async: true

  import Mox
  import WhalewatchApp.Factory
  alias WhalewatchApp.AlertsMock
  alias WhalewatchApp.AlertFilterMock
  alias WhalewatchApp.Watchers.EthWatcher
  alias WhalewatchApp.Tokens
  alias WhalewatchApp.Transactions

  describe "ETH watcher" do
    setup do
      AlertsMock
      |> expect(:list_eth_alerts, fn (_value, _from, _to) ->
        [%{user: %{ email: "test@test.com"}}]
      end)
      |> expect(:list_token_alerts, fn (_value, _from, _to, _contract_address) ->
        [%{user: %{ email: "test@test.com"}}]
      end)

      insert(:token, symbol: "CMCT", contract_address: "0x123", name: "Crowd Machine", decimals: 12, price: 15)
      insert(:token, symbol: "BNB", contract_address: "0xb8c77482e45f1f44de1745f52c74426c631bdd52", name: "Binance Token", decimals: 18, price: 900)
      insert(:token, symbol: "OCN", contract_address: "0x4092678e4e78230f46a1534c0fbc8fa39780892b", name: "OdysseyCoin", decimals: 18, price: 1)
      insert(:token, symbol: "DAI", contract_address: "0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359", name: "DAI", decimals: 18, price: 100)
      insert(:token, symbol: "ETH", contract_address: nil, name: "Ethereum", decimals: 18, price: 20000)
      block = insert(:block, hash: "0x111111111", number: 1)

      with {:ok, eth_fixture } <- File.read("test/fixtures/eth_block.json"),
           {:ok, eth_token_fixture } <- File.read("test/fixtures/eth_block_token.json"),
           {:ok, eth_fixture_below } <- File.read("test/fixtures/eth_block_below_thresh.json"),
           {:ok, eth_fixture_dai } <- File.read("test/fixtures/eth_block_dai.json"),
           {:ok, eth_block } <- Poison.decode(eth_fixture),
           {:ok, eth_block_below } <- Poison.decode(eth_fixture_below),
           {:ok, token_block } <- Poison.decode(eth_token_fixture),
           {:ok, dai_block } <- Poison.decode(eth_fixture_dai)
      do
        token_tx      = token_block["transactions"] |> List.first
        token_dai_tx  = dai_block["transactions"] |> List.first
        eth_tx        = eth_block["transactions"] |> List.first
        eth_tx_below  = eth_block_below["transactions"] |> List.first
        %{
          eth_block: eth_block, 
          eth_block_below: eth_block_below, 
          eth_tx_below: eth_tx_below, 
          token_block: token_block, 
          token_tx: token_tx, 
          eth_tx: eth_tx, 
          block: block,
          dai_block: dai_block,
          token_dai_tx: token_dai_tx
        }
      end
    end

    test "add_token_details/2 adds decimals, price, flag and synbol", %{token_tx: tx} do
      insert(:token, contract_address: "0xd26114cd6ee289accf82350c8d8487fedb8a0c07", symbol: "OMG2", price: 345, decimals: 18)
      updated_tx = EthWatcher.add_token_details(tx, Tokens.list_tokens)
      assert updated_tx |> Map.has_key?("symbol") == true
      assert updated_tx |> Map.has_key?("decimals") == true
      assert updated_tx |> Map.has_key?("price") == true
      assert updated_tx |> Map.has_key?("is_token_tx") == true
    end

    test "add_token_details/2 correctly marks token tx", %{token_tx: tx} do
      insert(:token, contract_address: "0xd26114cd6ee289accf82350c8d8487fedb8a0c07", symbol: "OMG", price: 345, decimals: 18)
      updated_tx = EthWatcher.add_token_details(tx, Tokens.list_tokens)
      assert updated_tx["is_token_tx"] == true
      assert updated_tx["decimals"] == 18
      assert updated_tx["price"] == 345
    end

    test "add_token_details/2 correctly marks eth tx", %{eth_tx: tx} do
      updated_tx = EthWatcher.add_token_details(tx, Tokens.list_tokens)

      assert updated_tx |> Map.has_key?("cents_value") == true
      assert "#{updated_tx["cents_value"]}" == "482520000"
      assert updated_tx["is_token_tx"] == false
      assert updated_tx["decimals"] == 18
      assert updated_tx["price"] == 20000
    end

    test "process_tx/1 processes eth tx", %{eth_tx: tx, block: block} do
      AlertFilterMock
      |> expect(:process_transaction, fn (%{value: "0xA967E1C9C85EB1060000"}) -> nil end)

      tx
        |> Map.put("value", "0xA967E1C9C85EB1060000")
        |> EthWatcher.add_token_details(Tokens.list_tokens)
        |> Map.put("block_id", block.id)
        |> EthWatcher.process_tx

      assert length(Transactions.list_transactions) == 1
    end

    @tag :skip
    test "process_tx/1 processes token tx", %{token_tx: tx, block: block} do
      AlertFilterMock
      |> expect(:process_transaction, fn (%{hash: "0x00d22086d8b84764cd9d400bcd3237d92a192d0ea2ae8bb1d9de25628c3a28e6"}) -> nil end)

      tx
        |> Map.put("hash", "0x00d22086d8b84764cd9d400bcd3237d92a192d0ea2ae8bb1d9de25628c3a28e6")
        |> EthWatcher.add_token_details(Tokens.list_tokens)
        |> Map.put("block_id", block.id)
        |> Map.put("symbol", "SYM")
        |> EthWatcher.process_tx

      saved_txs = Transactions.list_transactions

      assert length(saved_txs) == 1
      assert saved_txs |> Enum.at(0) |> Map.get(:hash) == "0x00d22086d8b84764cd9d400bcd3237d92a192d0ea2ae8bb1d9de25628c3a28e6"
    end

    test "process_tx/1 doesn't processes token tx if contract is unknown", %{token_tx: tx, block: block} do
      tx
        |> Map.put("to","nil")
        |> EthWatcher.add_token_details(Tokens.list_tokens)
        |> Map.put("block_id", block.id)
        |> Map.put("symbol", "SYM")
        |> EthWatcher.process_tx

      assert length(Transactions.list_transactions) == 0
    end

    @tag :skip
    test "process_tx/1 processes DAI tx", %{token_tx: tx, block: block} do
      AlertFilterMock
      |> expect(:process_transaction, fn (%{ hash: "0x2a02733412a074c1f05e6299755e4e395f7995b3ea45c9b8ab4be1750fae5ee1"}) -> nil end)

      tx
        |> Map.put("hash", "0x2a02733412a074c1f05e6299755e4e395f7995b3ea45c9b8ab4be1750fae5ee1")
        |> Map.put("to", "0x14fbca95be7e99c15cc2996c6c9d841e54b79425")
        |> Map.put("symbol", "DAI")
        |> EthWatcher.add_token_details(Tokens.list_tokens)
        |> Map.put("block_id", block.id)
        |> EthWatcher.process_tx

      saved_txs = Transactions.list_transactions

      assert length(saved_txs) == 1
      assert saved_txs |> Enum.at(0) |> Map.get(:hash) == "0x2a02733412a074c1f05e6299755e4e395f7995b3ea45c9b8ab4be1750fae5ee1"
    end

    test "process_eth_tx/2 doesn't process tx if value below threshold", %{eth_tx_below: tx, block: block} do
      AlertFilterMock
      |> expect(:process_transaction, fn (_tx) -> nil end)

      tx
        |> EthWatcher.add_token_details(Tokens.list_tokens)
        |> Map.put("block_id", block.id)
        |> EthWatcher.process_eth_tx

      assert length(Transactions.list_transactions) == 0
    end

    test "process_eth_tx/2 processes tx if value above threshold", %{eth_tx: tx, block: block} do
      AlertFilterMock
      |> expect(:process_transaction, fn (%{value: "0xA967E1C9C85EB1060000"}) -> nil end)

      tx
        |> Map.put("value", "0xA967E1C9C85EB1060000")
        |> EthWatcher.add_token_details(Tokens.list_tokens)
        |> Map.put("block_id", block.id)
        |> EthWatcher.process_eth_tx

      assert length(Transactions.list_transactions) == 1
    end

    test "process_token_tx/2 doesn't process tx if value below threshold", %{token_tx: tx, block: block} do
      tx
        |> Map.put("hash", "0x539b62cecc421269863e4cb4036f185face3acc45157b86ec59ac260f5c567e3")
        |> Map.put("to", "0x4092678e4e78230f46a1534c0fbc8fa39780892b")
        |> EthWatcher.add_token_details(Tokens.list_tokens)
        |> Map.put("block_id", block.id)
        |> EthWatcher.process_token_tx
      assert length(Transactions.list_transactions) == 0
    end

    @tag :skip
    test "process_token_tx/2 processes tx if value above threshold", %{token_tx: tx, block: block} do
      AlertFilterMock
      |> expect(:process_transaction, fn (%{hash: "0x2ca89c40b72bf8350a5cdec95fe1a41884250614a31bc996c99229a5ab76e8f0"}) -> nil end)

      tx
        |> Map.put("hash", "0x2ca89c40b72bf8350a5cdec95fe1a41884250614a31bc996c99229a5ab76e8f0")
        |> Map.put("to", "0xb8c77482e45f1f44de1745f52c74426c631bdd52")
        |> EthWatcher.add_token_details(Tokens.list_tokens)
        |> Map.put("block_id", block.id)
        |> EthWatcher.process_token_tx
      assert length(Transactions.list_transactions) == 1
    end

    @tag :skip
    test "process_token_tx/2 return correct values for txs", %{token_tx: tx, block: block} do
      AlertFilterMock
      |> expect(:process_transaction, fn (%{hash: "0x2ca89c40b72bf8350a5cdec95fe1a41884250614a31bc996c99229a5ab76e8f0"}) -> nil end)

      processed_tx =
        tx
        |> Map.put("hash", "0x2ca89c40b72bf8350a5cdec95fe1a41884250614a31bc996c99229a5ab76e8f0")
        |> Map.put("to", "0xb8c77482e45f1f44de1745f52c74426c631bdd52")
        |> EthWatcher.add_token_details(Tokens.list_tokens)
        |> Map.put("block_id", block.id)
        |> EthWatcher.process_token_tx

        assert processed_tx.from == "0x54da06d9679b2f63b896431ecce99571d976d855"
        assert processed_tx.to == "0x3f5ce5fbfe3e9af3971dd833d26ba9b5c936f0be"
        assert processed_tx.value == "0x000000000000000000000000000000000000000000000ba580739ecf2cfc0000"
        assert processed_tx.cents_value == 49499100
        assert processed_tx.is_token_tx == true
        assert processed_tx.contract_address == "0xb8c77482e45f1f44de1745f52c74426c631bdd52"
        assert processed_tx.hash == "0x2ca89c40b72bf8350a5cdec95fe1a41884250614a31bc996c99229a5ab76e8f0"
        assert processed_tx.token_amount == "54999"
    end

    @tag :skip
    test "process_transactions/3 for token transaction", %{ token_block: token_block } do
      AlertFilterMock
      |> expect(:process_transaction, fn (_transaction) -> nil end)

      insert(:token, contract_address: "0xd26114cd6ee289accf82350c8d8487fedb8a0c07", symbol: "OMG", price: 345, decimals: 18)

      txs           = token_block["transactions"]
      block         = insert(:block)
      tokens        = Tokens.list_tokens
      processed_tx  = EthWatcher.process_transactions(txs, block.id, tokens) |> List.first

      assert processed_tx.block_id          == block.id
      assert processed_tx.cents_value       == 172500000
      assert processed_tx.decimals          == 18
      assert processed_tx.symbol            == "OMG"
      assert processed_tx.contract_address  == "0xd26114cd6ee289accf82350c8d8487fedb8a0c07"
      assert processed_tx.from              == "0xd007058e9b58e74c33c6bf6fbcd38baab813cbb6"
      assert processed_tx.to                == "0xa04248bbbdae26fadc85e55ef79ec17ace948370"
      assert processed_tx.from_name         == "Unknown wallet"
      assert processed_tx.to_name           == "Unknown wallet"
      assert processed_tx.price             == 345
      assert processed_tx.is_token_tx       == true
      assert processed_tx.value             == "0x0000000000000000000000000000000000000000000069e10de76676d0800000"
      assert processed_tx.token_amount      == "500000"
      assert processed_tx.hash              == "0xa86a5857260093e6b262feb450b7ae5a1999cf7d476229ac5992dd4bf7b42553"

      saved_tx = Transactions.list_transactions |> List.first

      assert saved_tx.block_id == block.id
    end

    @tag :skip
    test "process_transactions/3 for dai token transaction", %{ dai_block: dai_block } do
      AlertFilterMock
      |> expect(:process_transaction, fn (_transaction) -> nil end)

      insert(:token, contract_address: "0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359", symbol: "DAI2", price: 99, decimals: 18)

      txs           = dai_block["transactions"]
      block         = insert(:block)
      tokens        = Tokens.list_tokens
      processed_tx  = EthWatcher.process_transactions(txs, block.id, tokens) |> List.first

      assert processed_tx.symbol            == "DAI"
      assert processed_tx.block_id          == block.id
      assert processed_tx.cents_value       == 3251900
      assert processed_tx.decimals          == 18
      assert processed_tx.contract_address  == "0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359"
      assert processed_tx.from              == "0xf3ae3bbdeb2fb7f9c32fbb1f4fbdaf1150a1c5ce"
      assert processed_tx.to                == "0xab8d8b74f202f4cd4a918b65da4bac612e086ee7"
      assert processed_tx.from_name         == "Unknown wallet"
      assert processed_tx.to_name           == "Unknown wallet"
      assert processed_tx.price             == 100
      assert processed_tx.is_token_tx       == true
      assert processed_tx.value             == "0x0000000000000000000000000000000000000000000006e2d8e80f07ebf7621a"
      assert processed_tx.token_amount      == "32519"
      assert processed_tx.hash              == "0x2fd2befb20960b4a7b50c3e2df1caf69855cdac469ccdce1791269adcac15bc9"

      saved_tx = Transactions.list_transactions |> List.first

      assert saved_tx.block_id == block.id
    end

    test "process_transactions/3 for eth transaction", %{ eth_block: eth_block } do
      AlertFilterMock
      |> expect(:process_transaction, fn (_transaction) -> nil end)

      txs           = eth_block["transactions"]
      block         = insert(:block)
      tokens        = Tokens.list_tokens
      processed_tx  = EthWatcher.process_transactions(txs, block.id, tokens) |> List.first

      assert processed_tx[:block_id]      ==  block.id
      assert processed_tx[:cents_value]   ==  482520000
      assert processed_tx[:decimals]      ==  18
      assert processed_tx[:from]          ==  "0x3f5ce5fbfe3e9af3971dd833d26ba9b5c936f0be"
      assert processed_tx[:to]            ==  "0x0681d8db095565fe8a346fa0277bffde9c0edbbf"
      assert processed_tx[:from_name]     ==  "Unknown wallet"
      assert processed_tx[:to_name]       ==  "Unknown wallet"
      assert processed_tx[:price]         ==  20000
      assert processed_tx[:is_token_tx]   ==  false
      assert processed_tx[:value]         ==  "0x51bdf8236f942380000"
      assert processed_tx[:token_amount]  ==  "24126"
      assert processed_tx[:hash]          ==  "0x846c342793f8c7ddb2c2cb13f465cb1d11de12d41735971845b5ab6fc8a91c02"

      saved_tx = Transactions.list_transactions |> List.first

      assert saved_tx.block_id == block.id
    end

    test "search_by_log_address/2 doesn't blow up with invalid params" do
      assert EthWatcher.search_by_log_address([], nil) == {0, 0, nil, nil}
      assert EthWatcher.search_by_log_address(nil, nil) == {0, 0, nil, nil}
    end

    test "search_by_log_address/2 doesn't blow up with valid params but no tokens found" do
      token_1 = insert(:token, symbol: "AAA", name: "One")
      token_2 = insert(:token, symbol: "BBB", name: "Two")

      assert EthWatcher.search_by_log_address([token_1, token_2], "0x34534534") == {0, 0, nil, nil}
    end

    test "find_by_address/2 doesn't blow up with invalid params" do
      assert EthWatcher.find_by_address(nil, nil) == nil
    end
  end
end
