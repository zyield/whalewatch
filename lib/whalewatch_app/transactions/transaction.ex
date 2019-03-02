defmodule WhalewatchApp.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  alias WhalewatchApp.AddressType
  alias WhalewatchApp.Transactions.Transaction
  alias WhalewatchApp.Blocks.{Block}

  schema "transactions" do
    field :to,    AddressType
    field :hash,  :binary
    field :from,  AddressType
    field :value, :binary
    field :contract_address, AddressType

    belongs_to :block, Block

    timestamps()
  end

  @allowed_fields [:hash, :block_id, :value, :to, :from, :contract_address]

  def changeset(%Transaction{} = transaction, attrs) do
    transaction
    |> cast(attrs, @allowed_fields )
    |> validate_required([:hash, :block_id])
    |> unique_constraint(:hash, name: :transactions_hash_block_id_index)
  end
end
