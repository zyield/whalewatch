defmodule WhalewatchApp.Repo.Migrations.AddHashToNotifications do
  use Ecto.Migration

  def change do
    alter table(:notifications) do
      add :hash, :bytea
    end
  end
end
