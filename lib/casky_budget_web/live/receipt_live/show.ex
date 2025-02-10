defmodule CaskyBudgetWeb.ReceiptLive.Show do
  alias CaskyBudget.Budgets.Budget
  alias CaskyBudget.Budgets
  use CaskyBudgetWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    receipt = Budgets.get_receipt!(id)

    socket =
      socket
      |> assign(:page_title, "View Receipt")
      |> assign(:receipt, receipt)
      |> assign(:form, to_form(Budgets.change_receipt_is_paid(receipt)))
      |> assign(:show_modal, false)

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

      <.button
        :if={!@receipt.is_approved}
        phx-click={show_modal("approval-confirm-receipt-#{@receipt.id}")}
      >
        Approve receipt
      </.button>

      <.modal
        id={"approval-confirm-receipt-#{@receipt.id}"}
        title="Approval confirmation"
        rounded="large"
        on_cancel={hide_modal("approval-confirm-receipt-#{@receipt.id}")}
      >
        <div :if={!@receipt.is_approved}>
          <h3>Are you sure you want to approve?</h3>
          <div class="flex gap-6">
            <.button phx-click={hide_modal("approval-confirm-receipt-#{@receipt.id}")}>
              Cancel
            </.button>
            <.button phx-click="approve_receipt">Confirm</.button>
          </div>
        </div>
        <div :if={@receipt.is_approved}>
          <h3>Receipt Approved.</h3>
          <div class="flex gap-6">
            <.back
              navigate={"/budget/subcategory/#{@receipt.sub_category_id}"}
              class="hover:text-blue-600"
            >
              Back to {@receipt.sub_category.name}
            </.back>
            <.button phx-click={hide_modal("approval-confirm-receipt-#{@receipt.id}")}>
              Close
            </.button>
          </div>
        </div>
      </.modal>
      <.button
        :if={@receipt.is_approved && !@receipt.is_paid}
        phx-click={show_modal("pay-receipt-#{@receipt.id}")}
      >
        Mark as paid
      </.button>
      <.modal
        id={"pay-receipt-#{@receipt.id}"}
        title="Mark as paid"
        rounded="large"
        on_cancel={hide_modal("pay-receipt-#{@receipt.id}")}
      >
        <div>
          <h3>Receipt Approved.</h3>
          <.simple_form
            for={@form}
            phx-change="validate"
            id="pay-receipt-form"
            phx-submit="mark_as_paid"
          >
            <.input label="Check number" field={@form[:check_number]} placeholder="Etx-3214" />
            <:actions>
              <.button>
                Mark as paid
              </.button>
            </:actions>
          </.simple_form>
          <div class="flex gap-6 mt-6 justify-end">
            <.button phx-click={hide_modal("approval-confirm-receipt-#{@receipt.id}")}>
              Cancel
            </.button>
          </div>
        </div>
      </.modal>
    </div>
    """
  end

  def handle_event("validate", %{"receipt" => receipt_params}, socket) do
    socket.assigns.receipt

    changeset = Budgets.change_receipt_is_paid(socket.assigns.receipt, receipt_params)
    IO.inspect(changeset)

    socket =
      socket
      |> assign(:form, to_form(changeset))

    {:noreply, socket}
  end

  def handle_event("mark_as_paid", %{"receipt" => receipt_params}, socket) do
    case Budgets.mark_receip_as_paid(socket.assigns.receipt, receipt_params["check_number"]) do
      {:ok, receipt} ->
        socket =
          socket
          |> assign(:receipt, receipt)

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, socket}
    end
  end

  def handle_event("approve_receipt", _params, socket) do
    case Budgets.approve_receipt(socket.assigns.receipt) do
      {:ok, receipt} ->
        hide_modal("approval-confirm-receipt-#{socket.assigns.receipt.id}")

        socket =
          socket
          |> assign(:receipt, receipt)
          |> put_flash(:info, "Receipt approved")
          |> assign(:show_modal, false)

        {:noreply, socket}

      {:error, _changeset} ->
        socket =
          socket
          |> put_flash(:error, "Oops something went wrong")

        {:noreply, socket}
    end
  end
end
