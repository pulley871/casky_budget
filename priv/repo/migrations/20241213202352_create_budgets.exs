defmodule CaskyBudget.Repo.Migrations.CreateBudgets do
  use Ecto.Migration

  def change do
    create table(:budgets) do
      add :year, :integer

      timestamps(type: :utc_datetime)
    end

    create unique_index(:budgets, [:year])
  end
end
