defmodule WhalewatchApp.Notifications.AlertFilter do
  use Task, restart: :transient

  @callback process_transaction(map) :: any
  @callback process_btc_transaction(map) :: any

  @alerts Application.get_env(:whalewatch_app, :alerts)
  @notification_message Application.get_env(:whalewatch_app, :notification_message)

  alias WhalewatchApp.Notifications.Notification
  alias WhalewatchApp.Repo

  def process_transaction(%{is_btc_tx: true} = tx) do
    @alerts.list_btc_alerts(
      tx.cents_value,
      tx.from,
      tx.to
    )
    |> Enum.each(fn alert ->
      Task.async(fn ->
        attrs = %{
          "user_id" => alert.user.id,
          "token_amount" => tx.token_amount,
          "symbol" => "BTC",
          "from_name" => tx.from_name,
          "to_name" => tx.to_name,
          "cents_value" => tx.cents_value,
          "to" => tx.to,
          "from" => tx.from
        }

        persist_notification(alert.user, attrs |> Map.put("hash", tx.hash))

        btc_message(alert, tx)  |> send
      end)
    end)
  end

  def process_transaction(%{is_token_tx: false} = tx) do
    @alerts.list_eth_alerts(
      tx.cents_value,
      tx.from,
      tx.to
    )
    |> Enum.each( fn (alert) ->
      attrs = %{
        "user_id" => alert.user.id,
        "token_amount" => tx.token_amount,
        "symbol" => "ETH",
        "from_name" => tx.from_name,
        "to_name" => tx.to_name,
        "cents_value" => tx.cents_value,
        "to" => tx.to,
        "from" => tx.from
      }

      persist_notification(alert.user, attrs |> Map.put("hash", tx.hash))

      Task.async(fn ->
        eth_message(alert, tx) |> send
      end)
    end)
  end

  def process_transaction(%{is_token_tx: true} = tx) do
    @alerts.list_token_alerts(
      tx.cents_value,
      tx.from,
      tx.to,
      tx.contract_address # second to is for the contract_address
    )
    |> Enum.each(fn (alert) ->
      Task.async(fn ->
        attrs = %{
          "user_id" => alert.user.id,
          "token_amount" => tx.token_amount,
          "symbol" => tx.symbol,
          "from_name" => tx.from_name,
          "to_name" => tx.to_name,
          "cents_value" => tx.cents_value,
          "to" => tx.to,
          "from" => tx.from
        }

        persist_notification(alert.user, attrs |> Map.put("hash", tx.hash))

        token_message(alert, tx) |> send
      end)
    end)
  end

  def btc_message(alert, tx) do
    %{
      email:        alert.user.email,
      token_amount: tx.token_amount,
      symbol:       "BTC",
      cents_value:  tx.cents_value,
      from:         {tx.from_name, tx.from},
      to:           {tx.to_name, tx.to},
      hash:         tx.hash
    }
  end

  def eth_message(alert, tx) do
    %{
      email:        alert.user.email,
      token_amount: tx.token_amount,
      symbol:       "ETH",
      cents_value:  tx.cents_value,
      from:         {tx.from_name, tx.from},
      to:           {tx.to_name, tx.to},
      hash:         tx.hash
    }
  end

  def token_message(alert, tx) do
    %{
      email:        alert.user.email,
      token_amount: tx.token_amount,
      symbol:       tx.symbol,
      cents_value:  tx.cents_value,
      from:         {tx.from_name, tx.from},
      to:           {tx.to_name, tx.to},
      hash:         tx.hash
    }
  end

  def persist_notification(user, attrs) do
    user
    |> Ecto.build_assoc(:notifications)
    |> Notification.changeset(attrs)
    |> Repo.insert!
  end

  def send(message) do
    message |> @notification_message.notification
    message
  end
end
