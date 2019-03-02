defmodule WhalewatchApp.Repo.Migrations.AddSymbolNameToAlerts do
  use Ecto.Migration

  def change do
    alter table(:alerts) do
      add :symbol_name, :string, null: true
    end

    create index :alerts, [:symbol, :symbol_name]
  end
end
