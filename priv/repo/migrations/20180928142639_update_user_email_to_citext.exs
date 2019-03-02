defmodule WhalewatchApp.Repo.Migrations.UpdateUserEmailToCitext do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION citext"
      
    alter table(:users) do
      modify :email, :citext, null: false
    end
  end

  def down do
    alter table(:users) do
      modify :email, :string, null: false
    end

    execute "DROP EXTENSION citext"
  end
end
