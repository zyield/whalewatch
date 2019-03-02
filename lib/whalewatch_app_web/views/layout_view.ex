defmodule WhalewatchAppWeb.LayoutView do
  use WhalewatchAppWeb, :view

  def full_errors(changeset) do
    for {key, {message, _}} <- changeset.errors do
      "#{key |> Atom.to_string |> String.capitalize} #{message}. "
    end
  end
end
