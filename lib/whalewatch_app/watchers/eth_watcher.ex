defmodule WhalewatchApp.Watchers.EthWatcher do
  use GenServer

  alias WhalewatchApp.{Blocks, Tokens}
  alias Tokens.Token
  alias WhalewatchApp.Transactions
  alias WhalewatchAppWeb.StreamChannel
  alias WhalewatchApp.Util

  @eth_threshold 250_000_00
  @token_threshold 25_000_00
  @transfer_signature "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"
  @notificator Application.get_env(:whalewatch_app, :notificator)

  def infura_api_key, do: Application.get_env(:whalewatch_app, :infura_api_key)
  def infura_url, do: "https://mainnet.infura.io/v3/#{infura_api_key()}"

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    work(nil)
    {:ok, state}
  end

  def work(prev_hash) do
    Process.sleep(1000)

    case get_latest_block() do
      {:ok, block = %{"hash" => hash}} ->
        unless prev_hash == hash, do: process_block(block)
        work(hash)
      {:error, _} ->
        work(prev_hash)
    end
  end

  def get_latest_block, do: query_jsonrpc("eth_getBlockByNumber", ["latest", true])

  def process_block(%{"hash" => hash, "number" => number, "transactions" => transactions}) do
    with {:ok, block} <- Blocks.create_block(%{hash: hash, number: Util.parse_value(number)}) do
      tokens = Tokens.list_tokens
      Task.start(fn ->
        process_transactions(transactions, block.id, tokens)
      end)
    end
  end

  def process_transactions(nil, _block_id, _tokens), do: nil
  def process_transactions(transactions, block_id, tokens) do
    transactions
    |> Enum.map(fn t -> t
      |> add_token_details(tokens)
      |> Map.put("block_id", block_id)
      end)
    |> Enum.map(&process_tx/1)
  end

  # Add decimals and price for what is most likely a pure ETH transaction
  # (based on input field)
  def add_token_details(tx = %{"input" => input, "value" => value}, tokens) when input == "0x" do
    %Token{decimals: decimals, price: price, symbol: symbol} = tokens |> Enum.find(&Util.is_eth?/1)

    formatted_value = value
                      |> Util.format_value(decimals)
                      |> Util.to_cents_value(price)

    token_amount = value
                |> Util.parse_value
                |> Util.to_token(decimals)
                |> Util.to_rounded(0)

    tx |> Map.merge(%{
      "symbol" => symbol,
      "token_amount" => "#{token_amount}",
      "decimals" => decimals,
      "price" => price,
      "cents_value" => formatted_value,
      "is_token_tx" => false
    })
  end
  # Add decimals and price for other txs
  def add_token_details(tx = %{"to" => to_address}, tokens) do
    case tokens |> find_by_address(to_address) do
      nil -> # unknown token transaction / transaction with non-empty input field
        tx |> Map.merge(%{
          "decimals" => 0,
          "price" => 0,
          "is_token_tx" => true,
          "tokens" => tokens,
          "contract_address" => nil
        })
      %Token{decimals: decimals, price: price, contract_address: contract_address, symbol: symbol} ->
        tx |> Map.merge(%{
          "symbol" => symbol,
          "decimals" => decimals,
          "price" => price,
          "is_token_tx" => true,
          "tokens" => nil,
          "contract_address" => contract_address
        })
    end
  end

  def process_tx(tx = %{"is_token_tx" => is_token_tx}) when is_token_tx == true do
    process_token_tx(tx)
  end
  def process_tx(tx) do
    process_eth_tx(tx)
  end

  def process_token_tx(%{"block_id" => block_id, "price" => price, "tokens" => tokens,
    "hash" => hash, "decimals" => decimals, "is_token_tx" => is_token_tx,
    "contract_address" => contract_address} = transaction)
  do
    with {:ok, %{"logs" => logs}} <- get_transaction_receipt(hash) do
      transfer_log = logs |> get_transfer_log

      unless is_nil transfer_log do
        address = transfer_log["address"]
        {decimals, price, contract_address, symbol} =
          if is_nil(contract_address),
            do: tokens |> search_by_log_address(address),
          else: {decimals, price, contract_address, transaction["symbol"]}

        {from, to, value} = transfer_log
                            |> decode_topics

        token_amount = value
                    |> Util.parse_value
                    |> Util.to_token(decimals)
                    |> Util.to_rounded(0)

        cents_value = token_amount
                      |> Util.to_cents_value(price)

        unless is_below_threshold?(cents_value, "token") do
          from_name = from |> Util.process_wallet_name
          to_name   = to |> Util.process_wallet_name

          %{
            from: from,
            from_name: from_name,
            value: value,
            to: to,
            price: price,
            to_name: to_name,
            token_amount: "#{token_amount}",
            block_id: block_id,
            decimals: decimals,
            symbol: symbol,
            cents_value: cents_value,
            is_token_tx: is_token_tx,
            hash: hash,
            contract_address: contract_address
          }
          |> create_and_notify
        end
      end
    end
  end

  def process_eth_tx(tx = %{"cents_value" => cents_value}) do
    unless is_below_threshold?(cents_value, "eth") do
      from_name = tx["from"] |> Util.process_wallet_name
      to_name   = tx["to"] |> Util.process_wallet_name

      %{
        from: tx["from"],
        to: tx["to"],
        from_name: from_name,
        to_name: to_name,
        symbol: "ETH",
        decimals: tx["decimals"],
        block_id: tx["block_id"],
        cents_value: tx["cents_value"],
        hash: tx["hash"],
        value: tx["value"],
        token_amount: tx["token_amount"],
        price: tx["price"],
        is_token_tx: tx["is_token_tx"]
      }
      |> create_and_notify
    end
  end

  def create_and_notify(transaction) do
    Transactions.create_transaction(transaction)
    @notificator.process_transaction(transaction)
    StreamChannel.send_tx("incoming_tx", transaction)
    transaction
  end

  def get_transfer_log(logs) when not is_nil(logs) and length(logs) > 0 do
    logs |> Enum.find(&is_transfer_log?/1)
  end
  def get_transfer_log(_), do: nil

  def get_transaction_receipt(hash) do
    # Receipt is not available for pending transactions and returns nil.
    query_jsonrpc("eth_getTransactionReceipt", [hash])
  end

  defp query_jsonrpc(method, params) do
    data = %{
      jsonrpc: "2.0",
      method: method,
      params: params,
      id: 1
    }
    headers = [{"Content-Type", "application/json"}]
    with {:ok, payload} <- Poison.encode(data),
         {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.post(infura_url(), payload, headers),
         {:ok, %{"result" => result}  } <- Poison.decode(body) do
      {:ok, result}

    end
  end

  defp decode_topics(%{"topics" => topics}) when length(topics) < 3, do: {0, 0, 0}
  defp decode_topics(%{"topics" => topics, "data" => data}) do
    from = topics |> Enum.at(1) |> String.slice(26..-1)
    to = topics |> Enum.at(2) |> String.slice(26..-1)

    {"0x" <> from, "0x" <> to, data}
  end

  def search_by_log_address([], _), do: {0, 0, nil, nil}
  def search_by_log_address(nil, _), do: {0, 0, nil, nil }
  def search_by_log_address(_tokens, nil), do: {0, 0, nil, nil}
  def search_by_log_address(tokens, address) do
    with %Token{decimals: decimals, price: price, contract_address: contract_address, symbol: symbol}
      <- tokens |> find_by_address(address) do
      {decimals, price, contract_address, symbol}
    else
      _ -> {0, 0, nil, nil}
    end
  end

  def find_by_address(nil, nil), do: nil
  def find_by_address(tokens, address) do
    tokens |> Enum.find(fn t -> t.contract_address == address end)
  end

  def is_transfer_log?(log), do: log["topics"] |> Enum.at(0) == @transfer_signature

  def is_below_threshold?(nil, _), do: true
  def is_below_threshold?(cents_value, "eth"),   do: cents_value < @eth_threshold
  def is_below_threshold?(cents_value, "token"), do: cents_value < @token_threshold
end
