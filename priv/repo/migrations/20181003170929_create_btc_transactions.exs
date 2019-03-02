defmodule WhalewatchApp.Repo.Migrations.CreateBtcTransactions do
  use Ecto.Migration

  def change do
    create table(:btc_transactions) do
      add :hash, :bytea, null: false
      add :from, :bytea
      add :to, :bytea
      add :value, :bigint

      timestamps()
    end

    create unique_index :btc_transactions, [:hash]
  end
end
