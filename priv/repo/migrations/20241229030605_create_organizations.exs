defmodule CaskyBudget.Repo.Migrations.CreateOrganizations do
  use Ecto.Migration

  def change do
    create table(:organizations) do
      add :name, :string
      add :address_line_one, :string
      add :address_line_two, :string
      add :city, :string
      add :state, :string
      add :postal_code, :string
      add :image_url, :string
      add :phone_number, :string

      timestamps(type: :utc_datetime)
    end
  end
end
