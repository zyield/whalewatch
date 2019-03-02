defmodule WhalewatchAppWeb.ConfirmController do
  use WhalewatchAppWeb, :controller

  import WhalewatchAppWeb.Authorize
  alias WhalewatchApp.Accounts
  alias WhalewatchApp.Accounts.User
  alias Phauxth.Confirm.Login
  alias WhalewatchApp.Alerts

  plug :put_layout, "onboarding.html"

  plug :guest_check when action in [:new, :create]

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{ "confirm" => params}) do
    case Accounts.get_by(%{ "email" => params["email"]}) do
      nil ->
        conn
        |> error("There no account with that email in our system", "/confirm/new")
      user ->
        case user.confirmed_at do
          nil ->
            key = Phauxth.Token.sign(conn, %{"email" => user.email})
            Accounts.Message.confirm_request(user.email, key, true)
            success(conn, "Please check your email to confirm your account", "/confirm/new")
          _ ->
            success(conn, "Your account is already confirmed, please use the Login link below to login.", "/confirm/new")
        end
    end
  end

  def index(conn, params) do
    case Phauxth.Confirm.verify(params, Accounts) do
      {:ok, user} ->
        Accounts.confirm_user(user)

        session_id = Login.gen_session_id("F")
        Accounts.add_session(user, session_id, System.system_time(:second))

        case params["onboarding"] do
          "true" ->
            changeset = User.changeset(user, %{})

            Alerts.activate_user_alerts(user.id)

            conn
            |> put_session(:phauxth_session_id, session_id <> to_string(user.id))
            |> render("index.html", changeset: changeset, user: user)
          _ ->
            Accounts.Message.confirm_success(user.email)
            Login.add_session(conn, session_id, user.id)
            |> login_success(alert_path(conn, :index))
        end

      {:error, _message} ->
        error(conn, "Looks like your confirmation token is either expired or doesn't exist.", "/confirm/new")
    end
  end
end
