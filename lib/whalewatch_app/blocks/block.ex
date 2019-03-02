defmodule WhalewatchApp.Blocks.Block do
  use Ecto.Schema
  import Ecto.Changeset
  alias WhalewatchApp.Blocks.Block

  schema "blocks" do
    field :number, :integer
    field :hash, :binary

    timestamps()
  end

  def changeset(%Block{} = block, attrs) do
    block
    |> cast(attrs, [:number, :hash])
    |> validate_required([:number, :hash])
    |> unique_constraint(:hash)
  end
end
