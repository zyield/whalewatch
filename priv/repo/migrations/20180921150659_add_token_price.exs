defmodule WhalewatchApp.Repo.Migrations.AddTokenPrice do
  use Ecto.Migration

  def change do
    alter table(:tokens) do
      add :price, :integer
    end
  end
end
