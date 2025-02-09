defmodule CaskyBudget.Admin do
  alias CaskyBudget.Accounts.UserOrganizations
  alias CaskyBudget.Accounts.User
  alias CaskyBudget.Repo
  import Ecto.Query, warn: false

  def list_all_roles() do
    Ecto.Enum.values(UserOrganizations, :role)
  end

  def change_user_role(params) do
    UserOrganizations.change_role_changeset(%UserOrganizations{}, params)
  end

  def update_user_role(role, %User{} = user, organization_id) do
    user_org =
      UserOrganizations
      |> where([u], u.user_id == ^user.id)
      |> where([u], u.organization_id == ^organization_id)
      |> Repo.one()

    case user_org do
      nil ->
        {:error, :not_found}

      user_org ->
        Repo.update(Ecto.Changeset.change(user_org, role: role))
    end
  end

  def search_for_user(filter) do
    User
    |> join(:inner, [u], ou in UserOrganizations, on: ou.user_id == u.id)
    |> where([u, ou], ou.organization_id == ^filter["organization_id"])
    |> filter_by_string(filter["q"])
    |> filter_by_role(filter["r"])
    |> select([u, ou], %{u | role: ou.role})
    |> Repo.all()
  end

  def get_user(id, organization_id) do
    User
    |> join(:inner, [u], ou in UserOrganizations, on: ou.user_id == u.id)
    |> where([u, ou], ou.organization_id == ^organization_id)
    |> select([u, ou], %{u | role: ou.role})
    |> Repo.get(id)
  end

  defp filter_by_role(query, r) when r in ["", nil], do: query

  defp filter_by_role(query, r) do
    query
    |> where(
      [u, ou],
      ou.role == ^r
    )
  end

  defp filter_by_string(query, q) when q in ["", nil], do: query

  defp filter_by_string(query, q) do
    query
    |> where(
      [u, _],
      ilike(u.first_name, ^"%#{q}%") or
        ilike(u.last_name, ^"%#{q}%") or
        ilike(u.email, ^"%#{q}%") or
        ilike(fragment("? || ' ' || ?", u.first_name, u.last_name), ^"%#{q}%")
    )
  end
end
