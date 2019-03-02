defmodule WhalewatchAppWeb.UserController do
  use WhalewatchAppWeb, :controller

  import WhalewatchAppWeb.Authorize
  alias WhalewatchApp.Accounts
  alias WhalewatchApp.Accounts.User
  alias WhalewatchApp.Repo

  alias Phauxth.Confirm.Login

  # the following plugs are defined in the controllers/authorize.ex file
  plug :user_check when action in [:index, :show]
  plug :id_check when action in [:edit, :update, :delete]
  plug :put_layout, "topnav.html" when action in [:edit, :update]

  def index(conn, _) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def new(conn, _) do
    changeset = Accounts.change_user(%Accounts.User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => %{"email" => email} = user_params}) do
    key = Phauxth.Token.sign(conn, %{"email" => email})
G
    case Accounts.create_user(user_params) do
      {:ok, _user} ->
        Accounts.Message.confirm_request(email, key)
        success(conn, "Please check your email to confirm your account", session_path(conn, :new))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    user = (id == to_string(user.id) and user) || Accounts.get(id)
    render(conn, "show.html", user: user)
  end

  def edit(%Plug.Conn{assigns: %{current_user: user}} = conn, _) do
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"user" => user_params, "type" => "onboarding"}) do
    changeset = User.onboarding_changeset(user, user_params)

    case user_params["password"] do
      "" ->
        conn
        |> put_flash(:error, "Password can't be blank")
        |> render("edit.html", user: user, changeset: changeset)
      _ ->
        case Repo.update(changeset) do
          {:ok, _user} ->
            success(conn, "User updated successfully", alert_path(conn, :index))

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "edit.html", user: user, changeset: changeset)
        end
    end
  end

  def update(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"user" => user_params, "type" => "account"}) do
    changeset = User.update_password_changeset(user, user_params)

    case user_params["password"] do
      "" ->
        conn
        |> put_flash(:error, "Current password can't be blank")
        |> render("edit.html", user: user, changeset: changeset)
      _ ->
        case Login.verify(user_params |> Map.put("email", user.email), Accounts) do
          {:ok, user } ->
            case Repo.update(changeset) do
              {:ok, _user } -> success(conn, "User updated successfully", alert_path(conn, :index))
              {:error, %Ecto.Changeset{} = changeset} ->
                IO.inspect changeset
                conn
                |> render("edit.html", user: user, changeset: changeset)
            end
          {:error, message } ->
            conn
            |> put_flash(:error, message)
            |> render("edit.html", user: user, changeset: changeset)
        end
    end
  end

  def delete(%Plug.Conn{assigns: %{current_user: user}} = conn, _) do
    {:ok, _user} = Accounts.delete_user(user)

    delete_session(conn, :phauxth_session_id)
    |> success("User deleted successfully", session_path(conn, :new))
  end
end
