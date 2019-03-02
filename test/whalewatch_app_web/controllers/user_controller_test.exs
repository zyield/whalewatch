defmodule WhalewatchAppWeb.UserControllerTest do
  use WhalewatchAppWeb.ConnCase

  import WhalewatchAppWeb.AuthCase

  @create_attrs %{email: "bill@example.com", password: "hard2guess"}
  @invalid_attrs %{email: nil}

  setup %{conn: conn} = config do
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

  test "renders form for new users", %{conn: conn} do
    conn = get(conn, user_path(conn, :new))

    assert Regex.match?(~r/Free\sSign\sUp/, html_response(conn, 200)) == true
  end

  test "creates user when data is valid", %{conn: conn} do
    conn = post(conn, user_path(conn, :create), user: @create_attrs)
    assert redirected_to(conn) == session_path(conn, :new)
  end

  test "does not create user and renders errors when data is invalid", %{conn: conn} do
    conn = post(conn, user_path(conn, :create), user: @invalid_attrs)
    assert length(conn.assigns.changeset.errors) > 0
  end
end
