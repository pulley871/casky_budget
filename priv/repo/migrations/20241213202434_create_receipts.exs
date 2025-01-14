defmodule CaskyBudget.Repo.Migrations.CreateReceipts do
  use Ecto.Migration

  def change do
    create table(:receipts) do
      add :amount, :decimal
      add :receipt_date, :date
      add :is_personal_payment, :boolean, default: false, null: false
      add :business_name, :string
      add :is_approved, :boolean, default: false, null: false
      add :check_is_cleared, :boolean, default: false, null: false
      add :is_paid, :boolean, default: false, null: false
      add :check_number, :string
      add :file_path, :string
      add :sub_category_id, references(:sub_categories, on_delete: :nothing)
      add :uploaded_by_user_id, references(:users, on_delete: :nothing)
      add :approved_by_user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:receipts, [:sub_category_id])
    create index(:receipts, [:uploaded_by_user_id])
    create index(:receipts, [:approved_by_user_id])
    create index(:receipts, [:receipt_date])
  end
end
