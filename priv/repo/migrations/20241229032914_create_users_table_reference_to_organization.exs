defmodule CaskyBudget.Repo.Migrations.CreateUsersTableReferenceToOrganization do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :organization_id, references(:organizations, on_delete: :nilify_all), null: true
    end
  end
end
