defmodule WhalewatchAppWeb.OnboardingView do
  use WhalewatchAppWeb, :view

  alias WhalewatchApp.Tokens
  alias WhalewatchApp.Wallets

  def tokens() do
    Tokens.list_tokens
  end

  def exchanges(type \\ :eth) do
    Wallets.list_wallets(type)
  end

  def full_errors(changeset) do
    for {key, {message, _}} <- changeset.errors do
      "#{key |> Atom.to_string |> String.capitalize} #{message}. "
    end
  end
end
