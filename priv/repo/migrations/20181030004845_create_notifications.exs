defmodule WhalewatchApp.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :from, :bytea, null: true
      add :to, :bytea, null: true
      add :to_name, :string, null: false, default: "Unknown Wallet"
      add :from_name, :string, null: false, default: "Unknown Wallet"
      add :cents_value, :bigint
      add :token_amount, :bigint
      add :symbol, :string, null: false

      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index :notifications, [:user_id]
  end
end
