defmodule WhalewatchApp.Wallets.Wallet do
  use Ecto.Schema
  import Ecto.Changeset

  alias WhalewatchApp.Wallets.Wallet
  alias WhalewatchApp.AddressType

  schema "wallets" do
    field :name, :string
    field :address, AddressType
    field :type, TokenType

    timestamps()
  end

  def changeset(%Wallet{} = exchange, attrs) do
    exchange
    |> cast(attrs, [:name, :address, :type])
    |> validate_required([:address, :type])
    |> unique_constraint(:address)
  end
end
