defmodule WhalewatchAppWeb.OnboardingControllerTest do
  use WhalewatchAppWeb.ConnCase

  import WhalewatchApp.Factory

  alias WhalewatchApp.Accounts
  alias WhalewatchApp.Alerts

  @create_attrs         %{ threshold: 1_000_000_00, email: "johnny@example.com", type: :eth }
  @create_attrs_ex      %{ threshold: 1_000_000_00, email: "johnny@example.com", exchange_name: "binance", type: :eth }
  @create_attrs_token   %{ threshold: 150_000_00, email: "johnny@example.com", exchange_name: "binance", symbol: "POLY", type: :erc20 }

  setup %{ conn: conn }do
    conn = conn 
           |> bypass_through(WhalewatchApp.Router, :browser) |> get("/")
    %{ conn: conn }
  end

  test "creates an eth alert with valid attributes", %{ conn: conn } do
    conn = get(conn, onboarding_path(conn, :new))
    assert html_response(conn, 200) =~ "Create an alert"

    conn = post(conn, onboarding_path(conn, :create), alert: @create_attrs)
    assert redirected_to(conn) == onboarding_path(conn, :new)

    user = Accounts.get_by(%{ "email" => "johnny@example.com"})
    alert = List.first(Alerts.list_alerts())

    assert user.email == "johnny@example.com"
    assert alert.user_id == user.id
    assert user.password_hash != nil
    assert alert.status == :inactive
    assert alert.threshold == 1_000_000_00
  end

  test "creates an eth alert with valid attributes for exchange", %{ conn: conn } do
    wallet = insert(:wallet, name: "binance", address: "0x123")

    conn = get(conn, onboarding_path(conn, :new))
    assert html_response(conn, 200) =~ "Create an alert"

    conn = post(conn, onboarding_path(conn, :create), alert: @create_attrs_ex)
    assert redirected_to(conn) == onboarding_path(conn, :new)

    user = Accounts.get_by(%{ "email" => "johnny@example.com"})
    alert = List.first(Alerts.list_alerts())

    assert user.email == "johnny@example.com"
    assert alert.user_id == user.id
    assert user.password_hash != nil
    assert alert.threshold == 1_000_000_00
    assert alert.status == :inactive
    assert List.first(alert.wallets).address == wallet.address
  end

  test "creates an eth alert with valid attributes for token and exchange", %{ conn: conn } do
    wallet  = insert(:wallet, name: "binance", address: "0x123")
    token   = insert(:token, symbol: "POLY", name: "Polymath")

    conn = get(conn, onboarding_path(conn, :new))
    assert html_response(conn, 200) =~ "Create an alert"

    conn = post(conn, onboarding_path(conn, :create), alert: @create_attrs_token)
    assert redirected_to(conn) == onboarding_path(conn, :new)

    user = Accounts.get_by(%{ "email" => "johnny@example.com"})
    alert = List.first(Alerts.list_alerts())

    assert user.email == "johnny@example.com"
    assert user.password_hash != nil
    assert alert.user_id == user.id
    assert alert.threshold == 150_000_00
    assert alert.contract_address == token.contract_address
    assert alert.status == :inactive
    assert alert.symbol == "POLY"
    assert List.first(alert.wallets).address == wallet.address
  end

  test "it throws an error if email already exists", %{ conn: conn } do
    insert(:user, email: "john.doe@example.com")

    conn = post(conn, onboarding_path(conn, :create), alert: %{ email: "john.doe@example.com", threshold: 10_000})
    assert html_response(conn, 200) =~ "Email has already been taken."
  end

  test "it throws an error if threshold is not present", %{ conn: conn } do
    conn = post(conn, onboarding_path(conn, :create), alert: %{ email: "john.doe@example.com"})
    assert html_response(conn, 200) =~ "Threshold can&#39;t be blank."
  end
end
