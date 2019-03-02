defmodule WhalewatchApp.AlertsTest do
  use WhalewatchApp.DataCase

  import WhalewatchApp.Factory

  alias WhalewatchApp.Alerts
  alias WhalewatchApp.Alerts.Alert

  setup do
    user = insert(:user)
    insert(:token, symbol: "POLY", contract_address: "0x9992ec3cf6a55b00978cddf2b27bc6882d88d1ec", name: "Polymath")

    wallet_1 = insert(:wallet)
    wallet_2 = insert(:wallet, address: "0xd551234ae421e3bcba99a0da6d736074f22192ff")
    wallet_3 = insert(:wallet, address: "0x3f5ce5fbfe3e9af3971dd833d26ba9b5c936f0be")
    wallets = [%Alert.Wallet{address: wallet_1.address}, %Alert.Wallet{address: wallet_2.address}, %Alert.Wallet{address: wallet_3.address}]

    alert = insert(:alert, user: user, wallets: wallets)
    %{ alert: alert, wallet_1: wallet_1, wallet_2: wallet_2, wallet_3: wallet_3, user: user }
  end

  describe "alerts" do
    alias WhalewatchApp.Alerts.Alert

    test "list_eth_alerts/2 does not return inactive alerts", %{ user: user } do
      insert(:user, email: "user_2@example.com") 
      wallet  = insert(:wallet, address: "0x40085aC85a444045C6E614e586afc2786721Eb6a")

      insert(:alert, user: user, threshold: 200_000, symbol: nil, contract_address: nil, status: :inactive)
      alert_2   = insert(:alert, user: user, threshold: 200_000, symbol: nil, contract_address: nil, status: :active)

      assert Alerts.list_eth_alerts(200_000, wallet.address, wallet.address) == [alert_2]
    end

    test "list_token_alerts/2 does not return inactive alerts", %{ user: user } do
      wallet  = insert(:wallet, address: "0x40085aC85a444045C6E614e586afc2786721Eb6a")
      alert_poly  = insert(:alert, symbol: "POLY", contract_address: "0x123poly", threshold: 125_000, user: user, status: :active)
      insert(:alert, symbol: "CMCT", contract_address: "0x234scam", threshold: 100_000, user: user)
      alert_dai   = insert(:alert, user: user, threshold: 150_000, symbol: "DAI", contract_address: "0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359", wallets: [%Alert.Wallet{address: wallet.address}], status: :inactive)

      assert Alerts.list_token_alerts(300_000, wallet.address, "0x123", alert_dai.contract_address) == []
      assert Alerts.list_token_alerts(150_000, wallet.address, "0x123", alert_poly.contract_address) == [alert_poly]
    end
  
    test "list_eth_alerts/2 returns filtered alerts", %{ user: user } do
      user_2  = insert(:user, email: "user_2@example.com") 
      wallet  = insert(:wallet, address: "0x40085aC85a444045C6E614e586afc2786721Eb6a")

      alert   = insert(:alert, user: user, threshold: 200_000, symbol: nil, contract_address: nil)
      alert_2 = insert(:alert, user: user_2, threshold: 300_000, symbol: nil, contract_address: nil)
      alert_3 = insert(:alert, user: user, threshold: 350_000, symbol: nil, contract_address: nil, wallets: [%Alert.Wallet{address: wallet.address}])

      insert(:alert, user: user, threshold: 200_000, symbol: nil, contract_address: nil, wallets: [%Alert.Wallet{address: "0x89789F898011e741A32d239A9bb81853E8ecfB5d"}])

      # No matches - threshold too small
      assert Alerts.list_eth_alerts(100_000, "0x123", "0x234") == []

      # Matches alert with 200k
      assert Alerts.list_eth_alerts(200_000, wallet.address, wallet.address) == [alert]

      # Matches 
      # - alert with 200k and no wallet address
      # - alert with 300k and no wallet address
      # - alert with 350k with wallet address
      assert Alerts.list_eth_alerts(350_000, wallet.address, wallet.address) == [alert, alert_2, alert_3] 

      # Matches
      # - alert with 200k and no wallet address
      # - alert with 300k and no wallet address
      assert Alerts.list_eth_alerts(350_000, "0x123", "0x123") == [alert, alert_2] 
    end

    test "list_token_alerts/4 returns filtered alerts", %{ user: user } do
      wallet  = insert(:wallet, address: "0x40085aC85a444045C6E614e586afc2786721Eb6a")
      alert_poly  = insert(:alert, symbol: "POLY", contract_address: "0x123poly", threshold: 125_000, user: user)
      insert(:alert, symbol: "CMCT", contract_address: "0x234scam", threshold: 100_000, user: user)
      alert_dai   = insert(:alert, user: user, threshold: 150_000, symbol: "DAI", contract_address: "0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359", wallets: [%Alert.Wallet{address: wallet.address}])

      assert Alerts.list_token_alerts(300_000, wallet.address, "0x123", alert_dai.contract_address) == [alert_dai]
      assert Alerts.list_token_alerts(125_000, "0x123", "0x234", "0x123poly") == [alert_poly]
      assert Alerts.list_token_alerts(100_000, "0x123", "0x234", "0x123poly") == []
    end

    test "list_alerts/0 returns all alerts", %{ alert: alert } do
      assert Alerts.list_alerts(%{ preload: [:user]}) == [alert]
    end

    test "get_alert!/1 returns the alert with given id", %{ alert: alert } do
      assert Alerts.get_alert!(alert.id, %{ preload: [:user]}) == alert
    end

    test "create_alert/1 with valid data creates a alert", %{ user: user, wallet_1: wallet_1, wallet_2: wallet_2, wallet_3: wallet_3 } do
      wallets = [%{address: wallet_1.address}, %{address: wallet_2.address}, %{address: wallet_3.address}]

      attrs = %{
        symbol: "POLY",
        threshold: 100_000_00,
        wallets: wallets
      }

      assert {:ok, %Alert{} = alert} = Alerts.create_alert(attrs, user)
      assert alert.contract_address == "0x9992ec3cf6a55b00978cddf2b27bc6882d88d1ec"
      assert alert.symbol == "POLY"
      assert alert.threshold == 100_000_00
    end

    test "create_alert/1 for eth alerts creates an alert", %{ user: user } do
      attrs = %{
        threshold: 1_000_000_00
      }

      assert {:ok, %Alert{} = alert } = Alerts.create_alert(attrs, user)
      assert alert.threshold == 1_000_000_00
      assert is_nil(alert.contract_address)
      assert is_nil(alert.symbol)
    end

    test "create_alert/1 for token we don't track returns an error", %{ user: user } do
      attrs = %{
        threshold: 50_000_00,
        symbol: "NO_THERE"
      }

      assert {:error, %Ecto.Changeset{}} = Alerts.create_alert(attrs, user)
    end

    test "create_alert/1 with invalid data returns error changeset", %{ user: user } do
      assert {:error, %Ecto.Changeset{}} = Alerts.create_alert(%{
        threshold: nil
      }, user)
    end

    test "update_alert/2 with invalid data returns error changeset", %{ alert: alert } do
      assert {:error, %Ecto.Changeset{}} = Alerts.update_alert(alert, %{ threshold: nil})
      assert alert == Alerts.get_alert!(alert.id, %{ preload: [:user]})
    end

    test "delete_alert/1 deletes the alert", %{ alert: alert } do
      assert {:ok, %Alert{}} = Alerts.delete_alert(alert)
      assert_raise Ecto.NoResultsError, fn -> Alerts.get_alert!(alert.id) end
    end

    test "change_alert/1 returns a alert changeset", %{ user: user } do
      alert = insert(:alert, user: user)
      assert %Ecto.Changeset{} = Alerts.change_alert(alert)
    end
  end
end
