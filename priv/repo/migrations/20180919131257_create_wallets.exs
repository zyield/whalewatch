defmodule WhalewatchApp.Repo.Migrations.CreateWallets do
  use Ecto.Migration

  def change do
    create table(:wallets) do
      add :name, :string, null: true
      add :address, :binary, null: false

      timestamps()
    end

    create unique_index :wallets, [:address]
  end
end
