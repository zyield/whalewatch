defmodule WhalewatchApp.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :hash, :bytea, null: false
      add :from, :bytea, null: true
      add :to, :bytea, null: true
      add :value, :bytea, null: true
      add :contract_address, :bytea, null: true

      add :block_id, references(:blocks, on_delete: :delete_all)

      timestamps()
    end

    create index :transactions, [:block_id]
    create unique_index :transactions, [:hash, :block_id]
  end
end
