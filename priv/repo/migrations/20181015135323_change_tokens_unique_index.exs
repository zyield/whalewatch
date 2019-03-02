defmodule WhalewatchApp.Repo.Migrations.ChangeTokensUniqueIndex do
  use Ecto.Migration

  def change do
    Ecto.Migration.execute "DROP INDEX tokens_symbol_index"

    create unique_index(:tokens, [:symbol, :name], name: :tokens_symbol_name_index)
  end
end
