defmodule CaskyBudget.Budgets.SubCategory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sub_categories" do
    field :name, :string
    field :amount_approved, :decimal
    field :slug, :integer
    field :spent, :decimal, virtual: true
    field :remaining, :decimal, virtual: true
    field :first_quarter_spent, :decimal, virtual: true
    field :second_quarter_spent, :decimal, virtual: true
    field :third_quarter_spent, :decimal, virtual: true
    field :fourth_quarter_spent, :decimal, virtual: true
    field :pending, :decimal, virtual: true
    belongs_to :category, CaskyBudget.Budgets.Category
    has_many :receipts, CaskyBudget.Budgets.Receipt
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(sub_category, attrs) do
    sub_category
    |> cast(attrs, [:name, :amount_approved])
    |> validate_required([:name, :amount_approved])
  end
end
