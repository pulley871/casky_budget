defmodule CaskyBudgetWeb.BudgetLive.Show do
  alias CaskyBudget.Budgets
  use CaskyBudgetWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Budget Line")

    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    socket =
      socket
      |> assign_async(:sub_category, fn ->
        {:ok, %{sub_category: Budgets.get_sub_category!(id)}}
      end)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="body-container">
      <.back navigate={~p"/budget"} class="hover:text-blue-600">Back to budget</.back>
      <.async_result :let={sub_category} assign={@sub_category}>
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
        <div class="flex flex-col mt-12 mb-12">
          <h1 class="text-xl font-bold">{sub_category.name}</h1>
        </div>
        <div class="flex justify-center items-center w-full mb-6">
          <div id="doughnut-chart" class="h-[300px]" phx-update="ignore">
            <canvas
              id={"doughnut-chart-#{sub_category.id}"}
              phx-hook="ChartJSDoughnut"
              data-points={
                Jason.encode!([
                  Decimal.to_string(Decimal.max(sub_category.remaining, Decimal.new(0))),
                  Decimal.to_string(sub_category.spent),
                  Decimal.to_string(sub_category.pending)
                ])
              }
            >
            </canvas>
          </div>
          <div id="bar-chart" class="flex items-end h-[300px]" phx-update="ignore">
            <canvas
              id={"bar-chart-#{sub_category.id}"}
              phx-hook="ChartJSBarChart"
              data-points={
                Jason.encode!([
                  Decimal.to_string(sub_category.first_quarter_spent),
                  Decimal.to_string(sub_category.second_quarter_spent),
                  Decimal.to_string(sub_category.third_quarter_spent),
                  Decimal.to_string(sub_category.fourth_quarter_spent)
                ])
              }
            >
            </canvas>
          </div>
        </div>
        <div class="w-full flex justify-center gap-12 text-gray-700">
          <div class="bg-white shadow-md rounded-lg p-6 w-64">
            <h3 class="text-xl font-semibold mb-4 pb-2 border-b border-gray-200">Budget Breakdown</h3>
            <div class="space-y-2">
              <div class="flex justify-between items-center">
                <span class="font-medium">Budgeted</span>
                <span class="font-bold text-gray-800">{sub_category.amount_approved}</span>
              </div>
              <div class="flex justify-between items-center">
                <span class="font-medium">Spent</span>
                <span class="font-bold text-blue-600">{sub_category.spent}</span>
              </div>
              <div class="flex justify-between items-center pt-2 border-t border-gray-200">
                <span class={"font-bold #{if Decimal.positive?(sub_category.remaining), do: "text-green-600", else: "text-red-500"}"}>
                  Remaining
                </span>
                <span class={"font-bold #{if Decimal.positive?(sub_category.remaining), do: "text-green-600", else: "text-red-500"}"}>
                  {sub_category.remaining}
                </span>
              </div>
            </div>
          </div>

          <div class="bg-white shadow-md rounded-lg p-6 w-64">
            <h3 class="text-xl font-semibold mb-4 pb-2 border-b border-gray-200">Projected Budget</h3>
            <div class="space-y-2">
              <div class="flex justify-between items-center">
                <span class="font-medium">Budgeted</span>
                <span class="font-bold text-gray-800">{sub_category.amount_approved}</span>
              </div>
              <div class="flex justify-between items-center">
                <span class="font-medium">Spent</span>
                <span class="font-bold text-blue-600">{sub_category.spent}</span>
              </div>
              <div class="flex justify-between items-center">
                <span class="font-medium">Pending</span>
                <span class="font-bold text-yellow-600">{sub_category.pending}</span>
              </div>
              <div class="flex justify-between items-center pt-2 border-t border-gray-200">
                <span class={"font-bold #{if Decimal.positive?(projected_remaining(sub_category)), do: "text-green-600", else: "text-red-600"}"}>
                  Remaining
                </span>
                <span class={"font-bold #{if Decimal.positive?(projected_remaining(sub_category)), do: "text-green-600", else: "text-red-600"}"}>
                  {projected_remaining(sub_category)}
                </span>
              </div>
            </div>
          </div>
        </div>
        <.tabs color="primary" id="receipts-tabs">
          <:tab>Approved Receipts</:tab>
          <:tab>Pending Receipts</:tab>
          <:panel>
            <div class="border-2 border-gray-300 p-6 rounded-lg" id="approved-list">
              <h4 class="text-lg font-bold">Approved Receipts</h4>

              <.table id="approved-receipts" rows={approved_receipts(sub_category)}>
                <:col :let={receipt} label="Submitted by">
                  <.link navigate="/">
                    {receipt.uploaded_by_user.email}
                  </.link>
                </:col>
                <:col :let={receipt} label="Date submitted">
                  <p>{receipt.receipt_date}</p>
                </:col>
                <:col :let={receipt} label="Is personal payment">
                  <%= if receipt.is_personal_payment do %>
                    <.icon name="hero-check-solid" class="bg-green-500" />
                  <% else %>
                    <.icon name="hero-x-mark-solid" class="bg-red-500" />
                  <% end %>
                </:col>
                <:col :let={receipt} label="Amount">
                  {receipt.amount}
                </:col>
                <:col :let={receipt} label="Business name">
                  {receipt.business_name}
                </:col>
                <:col :let={receipt} label="Approved">
                  <%= if receipt.is_approved do %>
                    <.icon name="hero-check-solid" class="bg-green-500" />
                  <% else %>
                    <.icon name="hero-x-mark-solid" class="bg-red-500" />
                  <% end %>
                </:col>
                <:col :let={receipt} label="Paid">
                  <%= if receipt.is_paid do %>
                    <.icon name="hero-check-solid" class="bg-green-500" />
                  <% else %>
                    <.icon name="hero-x-mark-solid" class="bg-red-500" />
                  <% end %>
                </:col>
                <:col :let={receipt} label="Check number">
                  {receipt.check_number || ~c""}
                </:col>
                <:col :let={receipt} label="Check is cleared">
                  <%= if receipt.check_is_cleared do %>
                    <.icon name="hero-check-solid" class="bg-green-500" />
                  <% else %>
                    <.icon name="hero-x-mark-solid" class="bg-red-500" />
                  <% end %>
                </:col>
                <:col :let={receipt} label="">
                  <.link
                    :if={@current_user.role == :admin}
                    navigate={~p"/receipt/#{receipt}"}
                    class="hover:text-blue-500"
                  >
                    <.icon name="hero-pencil-square" class="" />
                  </.link>
                </:col>
              </.table>
            </div>
          </:panel>
          <:panel>
            <div class="border-2 border-gray-300 p-6 rounded-lg" id="pending-list">
              <h4 class="text-lg font-bold">Pending Receipts</h4>
              <.table id="pending-receipts" rows={pending_receipts(sub_category)}>
                <:col :let={receipt} label="Submitted by">
                  <.link navigate="/">
                    {receipt.uploaded_by_user.email}
                  </.link>
                </:col>
                <:col :let={receipt} label="Date submitted">
                  <p>{receipt.receipt_date}</p>
                </:col>
                <:col :let={receipt} label="Is personal payment">
                  <%= if receipt.is_personal_payment do %>
                    <.icon name="hero-check-solid" class="bg-green-500" />
                  <% else %>
                    <.icon name="hero-x-mark-solid" class="bg-red-500" />
                  <% end %>
                </:col>
                <:col :let={receipt} label="Amount">
                  {receipt.amount}
                </:col>
                <:col :let={receipt} label="Business name">
                  {receipt.business_name}
                </:col>
                <:col :let={receipt} label="Approved">
                  <%= if receipt.is_approved do %>
                    <.icon name="hero-check-solid" class="bg-green-500" />
                  <% else %>
                    <.icon name="hero-x-mark-solid" class="bg-red-500" />
                  <% end %>
                </:col>
                <:col :let={receipt} label="">
                  <.link
                    :if={@current_user.role == :admin}
                    navigate={~p"/receipt/#{receipt}"}
                    class="hover:text-blue-500"
                  >
                    <.icon name="hero-pencil-square" class="" />
                  </.link>
                </:col>
              </.table>
            </div>
          </:panel>
        </.tabs>
      </.async_result>
    </div>
    """
  end

  defp approved_receipts(%{receipts: receipts}) do
    receipts
    |> Enum.filter(fn receipt -> receipt.is_approved end)
    # or remove :desc for ascending
    |> Enum.sort_by(& &1.receipt_date, {:desc, Date})
  end

  defp pending_receipts(%{receipts: receipts}) do
    receipts
    |> Enum.filter(fn receipt -> receipt.is_approved == false end)
    |> Enum.sort_by(& &1.receipt_date, {:asc, Date})
  end

  defp projected_remaining(%{remaining: remaining, pending: pending}) do
    case remaining > 0 do
      true ->
        Decimal.sub(remaining, pending)

      false ->
        Decimal.add(
          remaining,
          Decimal.mult(pending, Decimal.new(-1))
        )
    end
  end
end
