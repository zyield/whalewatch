defmodule WhalewatchApp.Repo.Migrations.ChangeTokensSymbolToRequired do
  use Ecto.Migration

  def change do
    Ecto.Migration.execute "ALTER TABLE tokens ALTER COLUMN symbol SET NOT NULL"
  end
end
