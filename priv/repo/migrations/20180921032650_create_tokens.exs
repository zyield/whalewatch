defmodule WhalewatchApp.Repo.Migrations.CreateTokens do
  use Ecto.Migration

  def change do
    Ecto.Migration.execute "CREATE TYPE type AS ENUM ('erc20', 'eth')"

    create table(:tokens) do
      add :contract_address, :binary
      add :name, :string
      add :type, :type
      add :decimals, :integer
      add :symbol, :string

      timestamps()
    end

    create unique_index(:tokens, [:contract_address, :name], name: :contract_address_name)
    create index :tokens, [:contract_address]
    create index :tokens, [:symbol]
    create index :tokens, [:type]
  end
end
