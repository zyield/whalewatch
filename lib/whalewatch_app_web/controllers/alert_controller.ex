defmodule WhalewatchAppWeb.AlertController do
  use WhalewatchAppWeb, :controller

  import WhalewatchAppWeb.Authorize
  alias WhalewatchApp.Alerts
  alias WhalewatchApp.Alerts.Alert
  alias WhalewatchApp.Wallets
  alias WhalewatchApp.Repo

  plug :user_check
  plug :put_layout, "topnav.html"

  def index(%Plug.Conn{assigns: %{current_user: user}} = conn, _params) do
    alerts = Repo.all(user_alerts(user))
    render(conn, "index.html", alerts: alerts)
  end

  def new(%Plug.Conn{assigns: %{current_user: user}} = conn, _params) do
    changeset =
      user
      |> Ecto.build_assoc(:alerts)
      |> Alert.changeset()

    render(conn, "new.html", changeset: changeset)
  end

  def create(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"alert" => alert_params}) do
    alert_params = case Map.has_key?(alert_params, "exchange_name") do
      true ->
        alert_params
        |> Map.merge(
          %{"wallets" => Wallets.list_for_name_and_type(alert_params["exchange_name"], alert_params["type"])})
      _ -> alert_params
    end

    alert_params = alert_params |> Map.put("status", "active")

    changeset =
      user
      |> Ecto.build_assoc(:alerts)
      |> Alert.changeset(alert_params)

    case Repo.insert(changeset) do
      {:ok, _alert} ->
        conn
        |> put_flash(:info, "Alert created successfully.")
        |> redirect(to: alert_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    alert = Alerts.get_alert!(id)
    render(conn, "show.html", alert: alert)
  end

  def edit(conn, %{"id" => id}) do
    alert = Alerts.get_alert!(id)
    changeset = Alerts.change_alert(alert)
    render(conn, "edit.html", alert: alert, changeset: changeset)
  end

  def update(conn, %{"id" => id, "alert" => alert_params}) do
    alert = Alerts.get_alert!(id)

    alert_params = case Map.has_key?(alert_params, "exchange_name") do
      true ->
        alert_params
        |> Map.merge(%{"wallets" => Wallets.list_for_name_and_type(alert_params["exchange_name"], alert.type)})
      _ -> alert_params
    end

    case Alerts.update_alert(alert, alert_params) do
      {:ok, _alert} ->
        conn
        |> put_flash(:info, "Alert updated successfully.")
        |> redirect(to: alert_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", alert: alert, changeset: changeset)
    end
  end

  def delete(%Plug.Conn{assigns: %{current_user: user}} = conn, %{"id" => id}) do
    alert = Repo.get!(user_alerts(user), id)
    {:ok, _alert} = Alerts.delete_alert(alert)

    conn
    |> put_flash(:info, "Alert deleted successfully.")
    |> redirect(to: alert_path(conn, :index))
  end

  defp user_alerts(user) do
    Ecto.assoc(user, :alerts)
  end
end
