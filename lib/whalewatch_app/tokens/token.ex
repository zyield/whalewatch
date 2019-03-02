defmodule WhalewatchApp.Tokens.Token do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tokens" do
    field :contract_address, :binary
    field :symbol, :string
    field :type, TokenType
    field :decimals, :integer
    field :name, :string
    field :price, :integer

    timestamps()
  end

  @doc false
  def changeset(token, attrs) do
    token
    |> cast(attrs, [:contract_address, :name, :decimals, :type, :symbol, :price])
    |> validate_required([:name, :type, :symbol])
    |> unique_constraint(:symbol)
  end
end
