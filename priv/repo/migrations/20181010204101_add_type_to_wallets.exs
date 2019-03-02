defmodule WhalewatchApp.Repo.Migrations.AddTypeToWallets do
  use Ecto.Migration

  def change do
    alter table(:wallets) do
      add :type, :type, null: false, default: "eth"
    end
  end
end
