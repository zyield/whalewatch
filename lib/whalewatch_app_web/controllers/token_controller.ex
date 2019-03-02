defmodule WhalewatchAppWeb.TokenController do
  use WhalewatchAppWeb, :controller

  alias WhalewatchApp.Tokens

  def index(conn, _params) do
    tokens = Tokens.list_tokens()
    render(conn, "index.json", %{tokens: tokens})
  end
end
