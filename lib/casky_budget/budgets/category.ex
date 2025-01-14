defmodule CaskyBudget.Budgets.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    belongs_to :budget, CaskyBudget.Budgets.Budget
    has_many :sub_categories, CaskyBudget.Budgets.SubCategory
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
