defmodule WhalewatchAppWeb.AlertControllerTest do
  use WhalewatchAppWeb.ConnCase

  import WhalewatchApp.Factory
  import WhalewatchAppWeb.AuthCase
  alias WhalewatchApp.Alerts

  @create_attrs %{contract_address: "0x123", symbol: "POLY", threshold: 100_000_00}
  @update_attrs %{contract_address: "0x234", symbol: "SALT", threshold: 110_000_00}
  @invalid_attrs %{contract_address: nil, symbol: nil, threshold: nil}

  setup %{ conn: conn } = config do
    insert(:token, symbol: "POLY", contract_address: "0x9992ec3cf6a55b00978cddf2b27bc6882d88d1ec", name: "Polymath")

    conn = conn |> bypass_through(WhalewatchAppWeb.Router, [:browser]) |> get("/")
    if email = config[:login] do
      user = add_user(email)
      other = add_user("tony@example.com")
      conn = conn |> add_phauxth_session(user) |> send_resp(:ok, "/")
      {:ok, %{conn: conn, user: user, other: other}}
    else
      {:ok, %{conn: conn}}
    end
  end

  def fixture(:alert) do
    {:ok, alert} = Alerts.create_alert(@create_attrs)
    alert
  end

  @tag login: "reg@example.com"
  describe "index" do
    test "lists all alerts", %{conn: conn} do
      conn = get conn, alert_path(conn, :index)
      assert html_response(conn, 200) =~ "My Alerts"
    end
  end

  describe "new alert" do
    @tag login: "reg@example.com"
    test "renders form", %{conn: conn} do
      conn = get conn, alert_path(conn, :new)
      assert html_response(conn, 200) =~ "New Alert"
    end
  end

  describe "create alert" do
    @tag login: "reg@example.com"
    test "creates an alert with the new token symbol and name data", %{ conn: conn } do
      attrs = %{
        threshold: 100_000_00,
        symbol: "POLY"
      }

      conn = post conn, alert_path(conn, :create), alert: attrs

      assert redirected_to(conn) == alert_path(conn, :index)

      alert = Alerts.list_alerts() |> List.first
      assert alert.status == :active
    end

    @tag login: "reg@example.com"
    test "creates an alert with symbol and wallets", %{ conn: conn } do
      attrs = %{
        threshold: 150_000_00,
        symbol: "POLY",
        wallets: [%{address: "0x123"}] 
      }

      conn = post conn, alert_path(conn, :create), alert: attrs

      assert redirected_to(conn) == alert_path(conn, :index)

      alert = Alerts.list_alerts() |> List.first
      assert alert.status == :active
      assert alert.symbol == "POLY"
    end

    @tag login: "reg@example.com"
    test "creates an alert with exchange_name", %{ conn: conn } do
      attrs = %{
        threshold: 150_000_00,
        exchange_name: "binance",
        type: :erc20
      }

      insert(:wallet, name: "binance", address: "0x123", type: :eth)
      insert(:wallet, name: "binance", address: "0x345", type: :eth)

      conn = post conn, alert_path(conn, :create), alert: attrs

      alert = List.first(Alerts.list_alerts)

      assert redirected_to(conn) == alert_path(conn, :index)
      assert Kernel.length(alert.wallets) == 2
    end

    @tag login: "reg@example.com"
    test "creates an alert with invalid exchange_name, sets wallet to empty", %{ conn: conn } do
      attrs = %{
        threshold: 100_000_00,
        exchange_name: "coinberry",
        type: :erc20
      }

      insert(:wallet, name: "binance", address: "0x123", type: :erc20)
      insert(:wallet, name: "binance", address: "0x345", type: :erc20)

      conn = post conn, alert_path(conn, :create), alert: attrs

      alert = List.first(Alerts.list_alerts)

      assert redirected_to(conn) == alert_path(conn, :index)
      assert Kernel.length(alert.wallets) == 0
    end

    @tag login: "reg@example.com"
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, alert_path(conn, :create), alert: @create_attrs

      assert redirected_to(conn) == alert_path(conn, :index)
    end

    @tag login: "reg@example.com"
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, alert_path(conn, :create), alert: @invalid_attrs
      assert html_response(conn, 200) =~ "New Alert"
    end
  end

  describe "edit alert" do
    setup [:create_alert]

    @tag login: "reg@example.com"
    test "renders form for editing chosen alert", %{conn: conn, alert: alert} do
      conn = get conn, alert_path(conn, :edit, alert)
      assert html_response(conn, 200) =~ "Edit Alert"
    end
  end

  describe "update alert" do
    setup [:create_alert]

    @tag login: "reg@example.com"
    test "redirects when data is valid", %{conn: conn, alert: alert} do
      insert(:token, symbol: "SALT", contract_address: "0x234", name: "Salt")
      conn = put conn, alert_path(conn, :update, alert), alert: @update_attrs
      assert redirected_to(conn) == alert_path(conn, :index)

      updated_alert = Alerts.get_alert!(alert.id)
      assert updated_alert.symbol == "SALT"
    end

    @tag login: "reg@example.com"
    test "renders errors when data is invalid", %{conn: conn, alert: alert} do
      conn = put conn, alert_path(conn, :update, alert), alert: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Alert"
    end

    @tag login: "reg@example.com"
    test "updates alert with exchange wallets", %{ conn: conn, alert: alert } do
      wallet = insert(:wallet, name: "Kraken", address: "0xkraken", type: :eth)
      assert alert.wallets == [] 
      conn = put conn, alert_path(conn, :update, alert), alert: %{ exchange_name: "Kraken" }

      assert redirected_to(conn) == alert_path(conn, :index)

      updated_alert = Alerts.get_alert!(alert.id)
      assert List.first(updated_alert.wallets).name == wallet.name
    end

    @tag login: "reg@example.com"
    test "updates alert and removes exchange", %{ conn: conn, alert: alert } do
      wallet = insert(:wallet, name: "Kraken", address: "0xkraken", type: :eth)
      assert alert.wallets == [] 
      conn = put conn, alert_path(conn, :update, alert), alert: %{ exchange_name: "Kraken" }
      assert redirected_to(conn) == alert_path(conn, :index)

      updated_alert = Alerts.get_alert!(alert.id)

      assert List.first(updated_alert.wallets).name == wallet.name

      conn = put conn, alert_path(conn, :update, alert), alert: %{ exchange_name: "" }
      assert redirected_to(conn) == alert_path(conn, :index)

      updated_alert = Alerts.get_alert!(alert.id)
      assert updated_alert.wallets == []
    end

    @tag login: "reg@example.com"
    test "updates alert and removes symbol", %{ conn: conn, alert: alert } do
      assert alert.symbol == "POLY"
      put conn, alert_path(conn, :update, alert), alert: %{ symbol: "" }

      updated_alert = Alerts.get_alert!(alert.id)
      assert updated_alert.contract_address == "0x0"
      assert updated_alert.symbol == nil
    end
  end

  describe "delete alert" do
    @tag login: "reg@example.com"
    test "deletes chosen alert", %{conn: conn, user: user} do
      alert = insert(:alert, user: user)
      conn = delete conn, alert_path(conn, :delete, alert)
      assert redirected_to(conn) == alert_path(conn, :index)
    end
  end

  defp create_alert(_) do
    user  = insert(:user)
    alert = insert(:alert, user: user)
    {:ok, alert: alert}
  end
end
