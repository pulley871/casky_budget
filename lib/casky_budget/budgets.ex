defmodule CaskyBudget.Budgets do
  @moduledoc """
  The Budgets context.
  """

  import Ecto.Query, warn: false
  alias CaskyBudget.Budgets.Receipt
  alias CaskyBudget.Budgets.SubCategory
  alias CaskyBudget.Repo

  alias CaskyBudget.Budgets.Budget

  @doc """
  Returns the list of budgets.

  ## Examples

      iex> list_budgets()
      [%Budget{}, ...]

  """
  def list_budgets do
    Repo.all(Budget)
  end

  @doc """
  Gets a single budget.

  Raises `Ecto.NoResultsError` if the Budget does not exist.

  ## Examples

      iex> get_budget!(123)
      %Budget{}

      iex> get_budget!(456)
      ** (Ecto.NoResultsError)

  """
  def get_budget!(id), do: Repo.get!(Budget, id)

  def get_budget_with_categories_and_subcategories(budget_id) do
    budget =
      Budget
      |> Repo.get(budget_id)
      |> Repo.preload(
        categories: [
          sub_categories: sub_category_custom_query()
        ]
      )

    budget
  end

  def get_budgets_for_select() do
    Budget
    |> Repo.all()
  end

  # defp with_custom_budget_fields(query) do
  #   query
  #   |> select_merge(
  #     ^%{
  #       total_spent: total_spent()
  #       # projected_savings: custom_projected_savings_subquery(),
  #       # # Add more custom virtual fields here
  #       # unusual_metric: custom_unusual_metric_subquery()
  #     }
  #   )
  # end

  # defp total_spent do
  #   from b in subquery(
  #     from b in Budget,
  #     left_join: sub in assoc(b, :sub_categories),
  #     left_join: r in assoc(sub, :receipts)
  #     select: fragment("SUM(expenses) as total_expenses")
  #   ), select: b.total_expenses
  # end

  defp sub_category_custom_query do
    current_year = DateTime.utc_now().year

    from sc in SubCategory,
      left_join: r in Receipt,
      on: r.sub_category_id == sc.id,
      group_by: [sc.id, sc.name, sc.amount_approved],
      select: %{
        sc
        | spent:
            coalesce(
              sum(fragment("CASE WHEN ? = true THEN ? ELSE 0 END", r.is_approved, r.amount)),
              0
            ),
          pending:
            coalesce(
              sum(fragment("CASE WHEN ? = false THEN ? ELSE 0 END", r.is_approved, r.amount)),
              0
            ),
          remaining:
            fragment(
              "? - COALESCE(SUM(CASE WHEN ? = true THEN ? ELSE 0 END), 0)",
              sc.amount_approved,
              r.is_approved,
              r.amount
            ),
          first_quarter_spent:
            coalesce(
              sum(
                fragment(
                  "CASE WHEN ? = true AND ? BETWEEN ?::date AND ?::date THEN ? ELSE 0 END",
                  r.is_approved,
                  r.receipt_date,
                  ^Date.new!(current_year, 1, 1),
                  ^Date.new!(current_year, 3, 31),
                  r.amount
                )
              ),
              0
            ),
          second_quarter_spent:
            coalesce(
              sum(
                fragment(
                  "CASE WHEN ? = true AND ? BETWEEN ?::date AND ?::date THEN ? ELSE 0 END",
                  r.is_approved,
                  r.receipt_date,
                  ^Date.new!(current_year, 4, 1),
                  ^Date.new!(current_year, 6, 30),
                  r.amount
                )
              ),
              0
            ),
          third_quarter_spent:
            coalesce(
              sum(
                fragment(
                  "CASE WHEN ? = true AND ? BETWEEN ?::date AND ?::date THEN ? ELSE 0 END",
                  r.is_approved,
                  r.receipt_date,
                  ^Date.new!(current_year, 7, 1),
                  ^Date.new!(current_year, 9, 30),
                  r.amount
                )
              ),
              0
            ),
          fourth_quarter_spent:
            coalesce(
              sum(
                fragment(
                  "CASE WHEN ? = true AND ? BETWEEN ?::date AND ?::date THEN ? ELSE 0 END",
                  r.is_approved,
                  r.receipt_date,
                  ^Date.new!(current_year, 10, 1),
                  ^Date.new!(current_year, 12, 31),
                  r.amount
                )
              ),
              0
            )
      }
  end

  @doc """
  Creates a budget.

  ## Examples

      iex> create_budget(%{field: value})
      {:ok, %Budget{}}

      iex> create_budget(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_budget(attrs \\ %{}) do
    %Budget{}
    |> Budget.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a budget.

  ## Examples

      iex> update_budget(budget, %{field: new_value})
      {:ok, %Budget{}}

      iex> update_budget(budget, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_budget(%Budget{} = budget, attrs) do
    budget
    |> Budget.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a budget.

  ## Examples

      iex> delete_budget(budget)
      {:ok, %Budget{}}

      iex> delete_budget(budget)
      {:error, %Ecto.Changeset{}}

  """
  def delete_budget(%Budget{} = budget) do
    Repo.delete(budget)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking budget changes.

  ## Examples

      iex> change_budget(budget)
      %Ecto.Changeset{data: %Budget{}}

  """
  def change_budget(%Budget{} = budget, attrs \\ %{}) do
    Budget.changeset(budget, attrs)
  end

  alias CaskyBudget.Budgets.Category

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories do
    Repo.all(Category)
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id), do: Repo.get!(Category, id)

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{data: %Category{}}

  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  alias CaskyBudget.Budgets.SubCategory

  @doc """
  Returns the list of sub_categories.

  ## Examples

      iex> list_sub_categories()
      [%SubCategory{}, ...]

  """
  def list_sub_categories do
    Repo.all(SubCategory)
  end

  def list_sub_categories_by_current_budget do
    year = DateTime.utc_now().year

    from(subcategory in SubCategory,
      join: category in assoc(subcategory, :category),
      join: budget in assoc(category, :budget),
      where: budget.year == ^year,
      select: subcategory
    )
    |> Repo.all()
  end

  @doc """
  Gets a single sub_category.

  Raises `Ecto.NoResultsError` if the Sub category does not exist.

  ## Examples

      iex> get_sub_category!(123)
      %SubCategory{}

      iex> get_sub_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sub_category!(id) do
    sub_category_custom_query()
    |> where([sc], sc.id == ^id)
    |> preload(receipts: [:uploaded_by_user])
    |> Repo.one!()
  end

  @doc """
  Creates a sub_category.

  ## Examples

      iex> create_sub_category(%{field: value})
      {:ok, %SubCategory{}}

      iex> create_sub_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sub_category(attrs \\ %{}) do
    %SubCategory{}
    |> SubCategory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sub_category.

  ## Examples

      iex> update_sub_category(sub_category, %{field: new_value})
      {:ok, %SubCategory{}}

      iex> update_sub_category(sub_category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sub_category(%SubCategory{} = sub_category, attrs) do
    sub_category
    |> SubCategory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a sub_category.

  ## Examples

      iex> delete_sub_category(sub_category)
      {:ok, %SubCategory{}}

      iex> delete_sub_category(sub_category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sub_category(%SubCategory{} = sub_category) do
    Repo.delete(sub_category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sub_category changes.

  ## Examples

      iex> change_sub_category(sub_category)
      %Ecto.Changeset{data: %SubCategory{}}

  """
  def change_sub_category(%SubCategory{} = sub_category, attrs \\ %{}) do
    SubCategory.changeset(sub_category, attrs)
  end

  alias CaskyBudget.Budgets.Receipt

  @doc """
  Returns the list of receipts.

  ## Examples

      iex> list_receipts()
      [%Receipt{}, ...]

  """
  def list_receipts do
    Repo.all(Receipt)
  end

  def list_receipts_by_user(user_id) do
    Receipt
    |> where(uploaded_by_user_id: ^user_id)
    |> preload(:sub_category)
    |> Repo.all()
  end

  @doc """
  Gets a single receipt.

  Raises `Ecto.NoResultsError` if the Receipt does not exist.

  ## Examples

      iex> get_receipt!(123)
      %Receipt{}

      iex> get_receipt!(456)
      ** (Ecto.NoResultsError)

  """
  def get_receipt!(id) do
    Receipt
    |> preload([:sub_category, :uploaded_by_user, :approved_by_user])
    |> where([r], r.id == ^id)
    |> Repo.one()
  end

  @doc """
  Creates a receipt.

  ## Examples

      iex> create_receipt(%{field: value})
      {:ok, %Receipt{}}

      iex> create_receipt(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_receipt(attrs \\ %{}) do
    %Receipt{}
    |> Receipt.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a receipt.

  ## Examples

      iex> update_receipt(receipt, %{field: new_value})
      {:ok, %Receipt{}}

      iex> update_receipt(receipt, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_receipt(%Receipt{} = receipt, attrs) do
    receipt
    |> Receipt.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a receipt.

  ## Examples

      iex> delete_receipt(receipt)
      {:ok, %Receipt{}}

      iex> delete_receipt(receipt)
      {:error, %Ecto.Changeset{}}

  """
  def delete_receipt(%Receipt{} = receipt) do
    Repo.delete(receipt)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking receipt changes.

  ## Examples

      iex> change_receipt(receipt)
      %Ecto.Changeset{data: %Receipt{}}

  """
  def change_receipt(%Receipt{} = receipt, attrs \\ %{}) do
    Receipt.changeset(receipt, attrs)
  end
end
