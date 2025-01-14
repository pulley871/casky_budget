defmodule CaskyBudget.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string
      add :budget_id, references(:budgets, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:categories, [:budget_id])
    create unique_index(:categories, [:budget_id, :name])
  end
end
