defmodule CaskyBudget.Repo.Migrations.CreateSubCategories do
  use Ecto.Migration

  def change do
    create table(:sub_categories) do
      add :name, :string
      add :amount_approved, :decimal
      add :category_id, references(:categories, on_delete: :nothing)
      add :slug, :integer

      timestamps(type: :utc_datetime)
    end

    create index(:sub_categories, [:category_id])
    create unique_index(:sub_categories, [:category_id, :name])
  end
end
