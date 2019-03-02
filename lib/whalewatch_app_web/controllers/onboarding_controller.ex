defmodule WhalewatchAppWeb.OnboardingController do
  use WhalewatchAppWeb, :controller

  import WhalewatchAppWeb.Authorize

  alias WhalewatchApp.Alerts.Alert
  alias WhalewatchApp.Accounts
  alias WhalewatchApp.Accounts.User
  alias WhalewatchApp.Repo
  alias WhalewatchApp.Wallets

  plug :put_layout, "onboarding.html"
  plug :guest_check when action in [:new, :create]

  def new(conn, _) do
    changeset = Alert.onboarding_changeset(%Alert{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{ "alert" => %{ "email" => email } = params }) do
    user_changeset = User.onboarding_changeset(%User{}, %{ email: email, password: Accounts.random_password(32)})
    key = Phauxth.Token.sign(conn, %{"email" => email})

    alert_params = case Map.has_key?(params, "exchange_name") do
      true -> 
        params
        |> Map.delete(:email)
        |> Map.merge(%{"wallets" => Wallets.list_for_name_and_type(params["exchange_name"], params["type"])})
      _ -> 
        params
        |> Map.delete(:email)
    end

    case Repo.insert(user_changeset) do
      {:ok, user } ->
        alert_changeset = user
                          |> Ecto.build_assoc(:alerts)
                          |> Alert.changeset(alert_params)

        case Repo.insert(alert_changeset) do
          {:ok, _alert } ->
            Accounts.Message.confirm_request(email, key, true)

            conn
            |> put_flash(:info, "Please check your email to confirm your account and start receiving alerts!")
            |> redirect(to: "/")

          {:error, %Ecto.Changeset{} = changeset } ->
            render(conn, "new.html", changeset: changeset)
        end
      {:error, %Ecto.Changeset{} = changeset } ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
