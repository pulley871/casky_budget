defmodule CaskyBudget.Budgets.Receipt do
  use Ecto.Schema
  import Ecto.Changeset

  schema "receipts" do
    field :amount, :decimal
    field :receipt_date, :date
    field :is_personal_payment, :boolean, default: false
    field :business_name, :string
    field :is_approved, :boolean, default: false
    field :is_paid, :boolean, default: false
    field :check_number, :string
    field :check_is_cleared, :boolean, default: false
    field :file_path, :string
    belongs_to :uploaded_by_user, CaskyBudget.Accounts.User
    belongs_to :approved_by_user, CaskyBudget.Accounts.User
    belongs_to :sub_category, CaskyBudget.Budgets.SubCategory
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(receipt, attrs) do
    receipt
    |> cast(attrs, [
      :amount,
      :receipt_date,
      :is_personal_payment,
      :business_name,
      :is_approved,
      :is_paid,
      :check_number,
      :file_path,
      :uploaded_by_user_id,
      :sub_category_id
    ])
    |> validate_required([
      :amount,
      # :receipt_date,
      :is_personal_payment,
      :business_name
      # :is_approved,
      # :is_paid,
      # :check_number,
      # :file_path
    ])
    |> validate_number(:amount, greater_than: 0.01)
  end
end
