defmodule WhalewatchApp.Repo.Migrations.UpdateWalletNameToCitext do
  use Ecto.Migration

  def change do
    alter table(:wallets) do
      modify :name, :citext, null: true
    end

    create index :wallets, [:name]
  end
end
