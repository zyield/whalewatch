defmodule WhalewatchAppWeb.SessionControllerTest do
  use WhalewatchAppWeb.ConnCase

  import WhalewatchAppWeb.AuthCase
  alias WhalewatchApp.Accounts

  @create_attrs %{email: "robin@example.com", password: "reallyHard2gue$$"}
  @invalid_attrs %{email: "robin@example.com", password: "cannotGue$$it"}
  @unconfirmed_attrs %{email: "lancelot@example.com", password: "reallyHard2gue$$"}
  @rem_attrs %{email: "robin@example.com", password: "reallyHard2gue$$", remember_me: "true"}
  @no_rem_attrs Map.merge(@rem_attrs, %{remember_me: "false"})

  setup %{conn: conn} do
    conn = conn |> bypass_through(WhalewatchAppWeb.Router, [:browser]) |> get("/")
    add_user("lancelot@example.com")
    user = add_user_confirmed("robin@example.com")
    {:ok, %{conn: conn, user: user}}
  end

  test "rendering login form fails for user that is already logged in", %{conn: conn, user: user} do
    conn = conn |> add_phauxth_session(user) |> send_resp(:ok, "/")
    conn = get(conn, session_path(conn, :new))
    assert redirected_to(conn) == alert_path(conn, :index)
  end

  test "login succeeds", %{conn: conn} do
    conn = post(conn, session_path(conn, :create), session: @create_attrs)
    assert redirected_to(conn) == alert_path(conn, :index)
  end

  test "login fails for user that is not yet confirmed", %{conn: conn} do
    conn = post(conn, session_path(conn, :create), session: @unconfirmed_attrs)
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "login fails for user that is already logged in", %{conn: conn, user: user} do
    conn = conn |> add_phauxth_session(user) |> send_resp(:ok, "/")
    conn = post(conn, session_path(conn, :create), session: @create_attrs)
    assert redirected_to(conn) == alert_path(conn, :index)
  end

  test "login fails for invalid password", %{conn: conn} do
    conn = post(conn, session_path(conn, :create), session: @invalid_attrs)
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "logout succeeds and session is deleted", %{conn: conn, user: user} do
    conn = conn |> add_phauxth_session(user) |> send_resp(:ok, "/")
    conn = delete(conn, session_path(conn, :delete, user))

    assert redirected_to(conn) == session_path(conn, :new)

    conn = get(conn, alert_path(conn, :index))

    assert redirected_to(conn) == session_path(conn, :new)
    assert Accounts.list_sessions(user.id) == %{}
  end

  test "redirects to previously requested resource", %{conn: conn} do
    conn = get(conn, alert_path(conn, :index))
    assert redirected_to(conn) == session_path(conn, :new)
    conn = post(conn, session_path(conn, :create), session: @create_attrs)
    assert redirected_to(conn) == alert_path(conn, :index)
  end

  test "remember me cookie is added / not added", %{conn: conn} do
    rem_conn = post(conn, session_path(conn, :create), session: @rem_attrs)
    assert rem_conn.resp_cookies["remember_me"]
    no_rem_conn = post(conn, session_path(conn, :create), session: @no_rem_attrs)
    refute no_rem_conn.resp_cookies["remember_me"]
  end
end
