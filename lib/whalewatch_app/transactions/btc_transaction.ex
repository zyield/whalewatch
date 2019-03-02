defmodule WhalewatchApp.Transactions.BtcTransaction do
  use Ecto.Schema
  import Ecto.Changeset

  alias WhalewatchApp.AddressType
  alias WhalewatchApp.Transactions.BtcTransaction

  schema "btc_transactions" do
    field :to,    AddressType
    field :hash,  :binary
    field :from,  AddressType
    field :value, :integer

    timestamps()
  end

  @allowed_fields [:hash, :value, :to, :from]

  def changeset(%BtcTransaction{} = btc_transaction, attrs) do
    btc_transaction
    |> cast(attrs, @allowed_fields)
    |> validate_required([:hash])
    |> unique_constraint(:hash)
  end
end
