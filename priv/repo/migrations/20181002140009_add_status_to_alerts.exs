defmodule WhalewatchApp.Repo.Migrations.AddStatusToAlerts do
  use Ecto.Migration

  def up do
    AlertStatus.create_type
    alter table(:alerts) do
      add :status, :status, null: false, default: "inactive"
    end
  end

  def down do
    alter table(:alerts) do
      remove :status
    end
    AlertStatus.drop_type
  end
end
