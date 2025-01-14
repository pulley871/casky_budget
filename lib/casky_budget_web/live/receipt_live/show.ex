defmodule CaskyBudgetWeb.ReceiptLive.Show do
  alias CaskyBudget.Budgets
  use CaskyBudgetWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    socket =
      socket
      |> assign(:page_title, "View Receipt")
      |> assign(:receipt, Budgets.get_receipt!(id))

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="p-10">
      <.back navigate={"/budget/subcategory/#{@receipt.sub_category_id}"} class="hover:text-blue-600">
        Back to {@receipt.sub_category.name}
      </.back>
      <h2 class="text-2xl font-bold text-gray-800">Receipt Details</h2>
      <div class="grid grid-cols-1 gap-4">
        <div>
          <p class="text-sm text-gray-500">Receipt Number</p>
          <p class="font-medium text-gray-900">{@receipt.id}</p>
        </div>
        <div>
          <p class="text-sm text-gray-500">Amount</p>
          <p class="font-medium text-gray-900">{@receipt.amount}</p>
        </div>
        <div>
          <p class="text-sm text-gray-500">Upload Date</p>
          <p class="font-medium text-gray-900">{@receipt.receipt_date}</p>
        </div>
        <div>
          <p class="text-sm text-gray-500">Uploaded By</p>
          <p class="font-medium text-gray-900">{@receipt.uploaded_by_user.email}</p>
        </div>
        <div>
          <p class="text-sm text-gray-500">Business Name</p>
          <p class="font-medium text-gray-900">{@receipt.business_name}</p>
        </div>
        <div>
          <p class="text-sm text-gray-500">Personal Payment?</p>
          <p class="font-medium text-gray-900">{@receipt.is_personal_payment}</p>
        </div>
        <div>
          <p class="text-sm text-gray-500">Is Approved?</p>
          <p class="font-medium text-gray-900">{@receipt.is_approved}</p>
        </div>
        <div>
          <p class="text-sm text-gray-500">Is Paid?</p>
          <p class="font-medium text-gray-900">{@receipt.is_paid}</p>
        </div>
        <div>
          <p class="text-sm text-gray-500">Check Number</p>
          <p class="font-medium text-gray-900">{@receipt.check_number}</p>
        </div>
        <div>
          <p class="text-sm text-gray-500">Check Cleared?</p>
          <p class="font-medium text-gray-900">{@receipt.check_is_cleared}</p>
        </div>
        <div :if={@receipt.approved_by_user}>
          <p class="text-sm text-gray-500">Approved by</p>
          <p class="font-medium text-gray-900">{@receipt.approved_by_user.email}</p>
        </div>
      </div>
    </div>
    """
  end
end
