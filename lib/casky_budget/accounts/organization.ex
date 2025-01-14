defmodule CaskyBudget.Accounts.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  schema "organizations" do
    field :name, :string
    field :state, :string
    field :address_line_one, :string
    field :address_line_two, :string
    field :city, :string
    field :postal_code, :string
    field :image_url, :string
    field :phone_number, :string

    many_to_many :users, CaskyBudget.Accounts.User,
      join_through: CaskyBudget.Accounts.UserOrganizations,
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [
      :name,
      :address_1,
      :city,
      :state,
      :postal_code,
      :image_url,
      :phone_number
    ])
    |> validate_required([
      :name,
      :address_1,
      :city,
      :state,
      :postal_code,
      :image_url,
      :phone_number
    ])
  end
end
