defmodule WhalewatchApp.Repo.Migrations.CreateAlerts do
  use Ecto.Migration

  def change do
    create table(:alerts) do
      add :symbol, :string, null: true
      add :contract_address, :bytea, null: true
      add :threshold, :bigint, null: false
      add :wallets, :jsonb, default: "[]"

      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index :alerts, [:wallets], using: :gin
    create index :alerts, [:user_id]
    create index :alerts, [:contract_address]
    create index :alerts, [:threshold]
    create index :alerts, [:contract_address, :threshold]
  end
end
