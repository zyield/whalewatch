defmodule WhalewatchApp.Repo.Migrations.AddTypeToAlerts do
  use Ecto.Migration

  def change do
    alter table(:alerts) do
      add :type, :type, null: false, default: "erc20"
    end
  end
end
