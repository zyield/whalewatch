defmodule WhalewatchApp.Repo.Migrations.UpdateTokenEnum do
  use Ecto.Migration
  @disable_ddl_transaction true

  def change do
    Ecto.Migration.execute "ALTER TYPE type ADD VALUE 'btc'"
    Ecto.Migration.execute "ALTER TYPE type ADD VALUE 'ltc'"
  end
end
