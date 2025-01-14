defmodule CaskyBudget.Accounts.UserOrganizations do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users_organizations" do
    field :role, :string, default: "user"

    belongs_to :user, CaskyBudget.Accounts.User
    belongs_to :organization, CaskyBudget.Accounts.Organization

    timestamps()
  end

  def changeset(user_organization, attrs) do
    user_organization
    |> cast(attrs, [:user_id, :organization_id, :role])
    |> validate_required([:user_id, :organization_id, :role])
  end
end
