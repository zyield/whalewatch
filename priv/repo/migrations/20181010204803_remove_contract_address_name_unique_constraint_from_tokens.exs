defmodule WhalewatchApp.Repo.Migrations.RemoveContractAddressNameUniqueConstraintFromTokens do
  use Ecto.Migration

  def change do
    Ecto.Migration.execute "DROP INDEX contract_address_name"
    Ecto.Migration.execute "DROP INDEX tokens_symbol_index"

    create unique_index(:tokens, [:symbol])
  end
end
