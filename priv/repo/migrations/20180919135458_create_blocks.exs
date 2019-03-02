defmodule WhalewatchApp.Repo.Migrations.CreateBlocks do
  use Ecto.Migration

  def change do
    create table(:blocks) do
      add :number, :integer
      add :hash, :binary

      timestamps()
    end

    create unique_index :blocks, [:hash]
  end
end
