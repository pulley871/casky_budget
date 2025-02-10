defmodule CaskyBudgetWeb.BudgetLive.Index do
  alias CaskyBudget.Budgets.Budget
  alias CaskyBudget.Budgets
  use CaskyBudgetWeb, :live_view

  def mount(_params, _session, socket) do
    budgets = Budgets.get_budgets_for_select()

    socket =
      socket
      |> assign(:page_title, "Budget")
      |> assign(:budgets, budgets)
      |> assign(:selected_budget, List.last(budgets).id)
      |> assign_async(:budget, fn ->
        budget = Budgets.get_budget_with_categories_and_subcategories(List.last(budgets).id)

        budget =
          budget
          |> Map.put(:total_amount, get_budget_total(budget))
          |> Map.put(:total_spent, get_total_spent(budget))

        {:ok, %{budget: budget}}
      end)

    {:ok, socket}
  end

  defp get_budget_total(%Budget{} = budget) do
    budget.categories
    |> Enum.reduce(0, fn category, acc ->
      amount =
        Enum.reduce(category.sub_categories, 0, fn sub_category, acc ->
          acc + Decimal.to_integer(sub_category.amount_approved)
        end)

      acc + amount
    end)
  end

  defp get_total_spent(%Budget{} = budget) do
    budget.categories
    |> Enum.reduce(0, fn category, acc ->
      amount =
        Enum.reduce(category.sub_categories, 0, fn sub_category, acc ->
          acc + Decimal.to_integer(sub_category.spent)
        end)

      acc + amount
    end)
  end

  def handle_event("change_budget", %{"budget-select" => budget_id}, socket) do
    socket =
      socket
      |> assign(:selected_budget, budget_id)
      |> assign_async(:budget, fn ->
        budget = Budgets.get_budget_with_categories_and_subcategories(budget_id)

        budget =
          budget
          |> Map.put(:total_amount, get_budget_total(budget))
          |> Map.put(:total_spent, get_total_spent(budget))

        {:ok, %{budget: budget}}
      end)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="p-6">
      <.form phx-change="change_budget" class="mb-12 w-full md:w-32" for={%{}}>
        <.input
          type="select"
          label="Select a budget"
          name="budget-select"
          options={Enum.map(@budgets, fn budget -> {budget.year, budget.id} end)}
          value={@selected_budget}
        />
      </.form>
      <.async_result :let={budget} assign={@budget}>
        <:loading>
          <div class="loading">
            <div class="spinner"></div>
          </div>
        </:loading>
        <:failed :let={{:error, reason}}>
          <div class="failed">
            Yikes: {reason}
          </div>
        </:failed>
        <h1 class="text-xl mb-2">Budget year {budget.year}</h1>

        <table class="table-auto border-collapse border border-gray-400 w-full">
          <thead>
            <th class="border border-gray-400 px-4 py-2">Code</th>
            <th class="border border-gray-400 px-4 py-2">Sub Category</th>
            <th class="border border-gray-400 px-4 py-2">Amount Approved</th>
            <th class="border border-gray-400 px-4 py-2">Spent</th>
            <th class="border border-gray-400 px-4 py-2">Remaining</th>
          </thead>
          <tbody :for={category <- budget.categories}>
            <!-- Category Row -->
            <tr class="bg-black text-white font-bold">
              <td class="border border-gray-400 px-4 py-2" colspan="5">
                {category.name}
              </td>
            </tr>
            
    <!-- Sub-Category Rows -->
            <div :for={sub_category <- category.sub_categories}>
              <tr class="bg-white hover:cursor-pointer hover:bg-gray-200">
                <td class="border border-gray-400 px-4 py-2">{sub_category.id}</td>
                <td class="border border-gray-400 px-4 py-2">
                  <.link navigate={~p"/budget/subcategory/#{sub_category.id}"}>
                    {sub_category.name}
                  </.link>
                </td>
                <td class="border border-gray-400 px-4 py-2 text-right">
                  {Decimal.to_string(sub_category.amount_approved)}
                </td>
                <td class="border border-gray-400 px-4 py-2 text-right">
                  {Decimal.to_string(sub_category.spent)}
                </td>
                <td class="border border-gray-400 px-4 py-2 text-right">
                  {Decimal.to_string(sub_category.remaining)}
                </td>
              </tr>
            </div>
          </tbody>
        </table>
      </.async_result>
    </div>
    """
  end
end
