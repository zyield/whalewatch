defmodule WhalewatchAppWeb.TokenView do
  use WhalewatchAppWeb, :view

  alias WhalewatchAppWeb.TokenView

  def render("index.json", %{ tokens: tokens }) do
    render_many(tokens, TokenView, "token.json")
  end

  def render("token.json", %{ token: token }) do
    %{
      symbol: token.symbol
    }
  end
end
