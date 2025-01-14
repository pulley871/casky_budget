defmodule CaskyBudget.Repo.Migrations.CreateUsersOrganizationsJoinTable do
  use Ecto.Migration

  def change do
    create table(:users_organizations) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :organization_id, references(:organizations, on_delete: :delete_all), null: false
      # Can be "admin" or "user"
      add :role, :string, null: false, default: "user"

      timestamps()
    end

    # Prevent duplicates
    create unique_index(:users_organizations, [:user_id, :organization_id])
  end
end
