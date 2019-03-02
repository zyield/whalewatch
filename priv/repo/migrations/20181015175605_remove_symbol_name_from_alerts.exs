defmodule WhalewatchApp.Repo.Migrations.RemoveSymbolNameFromAlerts do
  use Ecto.Migration

  def change do
    alter table(:alerts) do
      remove :symbol_name
    end
  end
end
