defmodule WhalewatchAppWeb.PageController do
  use WhalewatchAppWeb, :controller

  plug :put_layout, "topnav.html"

  def terms(conn, _params) do
    render(conn, "terms.html")
  end

  def privacy(conn, _params) do
    render(conn, "privacy.html")
  end
end
