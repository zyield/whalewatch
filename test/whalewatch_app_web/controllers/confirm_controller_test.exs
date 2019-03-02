defmodule WhalewatchAppWeb.ConfirmControllerTest do
  use WhalewatchAppWeb.ConnCase

  import WhalewatchApp.Factory
  import WhalewatchAppWeb.AuthCase
  alias WhalewatchApp.Accounts
  alias WhalewatchApp.Alerts

  setup %{conn: conn} do
    conn = conn |> bypass_through(WhalewatchApp.Router, :browser) |> get("/")
    add_user("arthur@example.com")
    {:ok, %{conn: conn}}
  end

  test "confirmation succeeds for onboarding", %{conn: conn} do
    user = insert(:user)
    insert(:alert, user: user, status: :inactive)
    conn = get(conn, confirm_path(conn, :index, key: gen_key(user.email), onboarding: true))
    assert html_response(conn, 200) =~ "Please type a password in the field below to complete your account registration."

    conn = put(conn, user_path(conn, :update, user), user: %{ password: "123ssasdz" }, type: "onboarding")
    assert redirected_to(conn) == alert_path(conn, :index)

    user = Accounts.get_by(%{"email" => user.email})
    assert user.password_hash != nil

    alert = List.first(Alerts.list_alerts())
    assert alert.status == :active
  end

  test "confirmation succeeds for correct key", %{conn: conn} do
    conn = get(conn, confirm_path(conn, :index, key: gen_key("arthur@example.com")))
    assert conn.private.phoenix_flash["info"] =~ "You have been logged in"
    assert redirected_to(conn) == alert_path(conn, :index)
  end

  test "confirmation fails for incorrect key", %{conn: conn} do
    conn = get(conn, confirm_path(conn, :index, key: "garbage"))
    assert conn.private.phoenix_flash["error"] =~ "Looks like your confirmation token is either expired or doesn't exist."
    assert redirected_to(conn) == "/confirm/new"
  end

  test "confirmation fails for incorrect email", %{conn: conn} do
    conn = get(conn, confirm_path(conn, :index, key: gen_key("gerald@example.com")))
    assert conn.private.phoenix_flash["error"] =~ "Looks like your confirmation token is either expired or doesn't exist."
    assert redirected_to(conn) == "/confirm/new"
  end
end
