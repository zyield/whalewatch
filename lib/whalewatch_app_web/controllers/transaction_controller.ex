defmodule WhalewatchAppWeb.TransactionController do
  use WhalewatchAppWeb, :controller

  import WhalewatchAppWeb.Authorize

  alias WhalewatchApp.Accounts
  alias WhalewatchApp.Notifications

  plug :user_check
  plug :put_layout, "topnav.html"

  def index(%Plug.Conn{assigns: %{ current_user: user }} = conn, params) do
    has_alerts = Accounts.has_alerts(user)
    page = Notifications.past24h_for_user(user, params)

    render conn, :index,
      notifications: page.entries,
      page: page,
      page_number: page.page_number,
      page_size:  page.page_size,
      total_pages: page.total_pages,
      total_entries: page.total_entries,
      has_alerts: has_alerts
  end
end
