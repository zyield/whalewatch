defmodule WhalewatchApp.Repo.Migrations.UpdateTokensSymbolIndexes do
  use Ecto.Migration

  def change do
    Ecto.Migration.execute "DROP INDEX tokens_symbol_name_index"

    create unique_index(:tokens, [:symbol])
  end
end
