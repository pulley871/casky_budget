defmodule CaskyBudget.Budgets.Budget do
  use Ecto.Schema
  import Ecto.Changeset

  schema "budgets" do
    field :year, :integer
    has_many :categories, CaskyBudget.Budgets.Category
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(budget, attrs) do
    budget
    |> cast(attrs, [:year])
    |> validate_required([:year])
  end
end
