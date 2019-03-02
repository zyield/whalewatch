defmodule WhalewatchAppWeb.UserView do
  use WhalewatchAppWeb, :view
  alias WhalewatchAppWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      email: user.email}
  end

  def full_errors(changeset) do
    for {key, {message, _}} <- changeset.errors do
      "#{key |> Atom.to_string |> String.capitalize} #{message}. "
    end
  end
end
