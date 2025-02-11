defmodule CaskyBudgetWeb.ReceiptLive.Index do
  alias CaskyBudget.Budgets.Receipt
  alias CaskyBudget.Budgets
  use CaskyBudgetWeb, :live_view

  def mount(_params, _session, socket) do
    receipt = %Receipt{}
    changeset = Budgets.change_receipt(receipt)
    user_id = socket.assigns.current_user.id

    socket =
      socket
      |> assign(:page_title, "My Receipts")
      |> assign(:show_modal, false)
      |> assign(:sub_categories, Budgets.list_sub_categories_by_current_budget())
      |> assign(:form, to_form(changeset))
      |> assign(:receipt, receipt)
      |> assign_async(:receipts, fn ->
        receipts = Budgets.list_receipts_by_user(user_id)

        {:ok, %{receipts: receipts}}
      end)

    {:ok, socket}
  end

  def handle_event("validate", %{"receipt" => params}, socket) do
    changeset = Budgets.change_receipt(socket.assigns.receipt, params)

    socket =
      socket
      |> assign(:form, to_form(changeset, action: :validate))

    {:noreply, socket}
  end

  def handle_event("save", %{"receipt" => params}, socket) do
    params =
      params
      |> Map.put("uploaded_by_user_id", socket.assigns.current_user.id)
      |> Map.put("receipt_date", Date.utc_today())

    IO.inspect(params)

    case Budgets.create_receipt(params) do
      {:ok, _receipt} ->
        socket =
          socket
          |> put_flash(:info, "Successfully created receipt")
          |> push_navigate(to: ~p"/my-receipts")

        {:noreply, socket}

      {:error, changeset} ->
        # IO.inspect(changeset)
        socket = assign(socket, :form, to_form(changeset))
        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="p-6">
      <div class="flex justify-between">
        <h1 class="text-xl font-bold mb-12">My receipts</h1>
        <.button phx-click={show_modal("create-receipt-modal-#{@current_user.id}")} class="h-12">
          Add receipt
        </.button>
      </div>
      <.async_result :let={receipts} assign={@receipts}>
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
        <.tabs color="primary" id="receipts-tabs">
          <:tab>Approved Receipts</:tab>
          <:tab>Pending Receipts</:tab>
          <:panel>
            <div class="border-2 border-gray-300 p-6 rounded-lg" id="approved-list">
              <h4 class="text-lg font-bold">Approved Receipts</h4>

              <.table id="approved-receipts" rows={approved_receipts(receipts)}>
                <:col :let={receipt} label="Date submitted">
                  <p>{receipt.receipt_date}</p>
                </:col>
                <:col :let={receipt} label="Category">
                  <p>{receipt.sub_category.name}</p>
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
              </.table>
            </div>
          </:panel>
          <:panel>
            <div class="border-2 border-gray-300 p-6 rounded-lg" id="pending-list">
              <h4 class="text-lg font-bold">Pending Receipts</h4>
              <.table id="pending-receipts" rows={pending_receipts(receipts)}>
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
              </.table>
            </div>
          </:panel>
        </.tabs>
        <.modal
          id={"create-receipt-modal-#{@current_user.id}"}
          title="Add receipt"
          on_cancel={hide_modal("create-receipt-modal-#{@current_user.id}")}
        >
          <div class="space-y-4">
            <p>
              Are you sure you want to delete this ite?
            </p>
            <.simple_form
              for={@form}
              class="flex flex-col gap-4"
              id="receipt-form"
              phx-change="validate"
              phx-submit="save"
            >
              <.input
                type="select"
                label="Select a Category"
                options={
                  Enum.map(@sub_categories, fn sub_category ->
                    {sub_category.name, sub_category.id}
                  end)
                }
                field={@form[:sub_category_id]}
              />
              <.input type="number" label="How much is this receipt for?" field={@form[:amount]} />
              <.input type="text" label="Where was the purchase made?" field={@form[:business_name]} />
              <.input
                type="checkbox"
                field={@form[:is_personal_payment]}
                label="Paid with personal funds?"
              />
              <:actions>
                <.button>Add Receipt</.button>
              </:actions>
            </.simple_form>
          </div>
        </.modal>
      </.async_result>
    </div>
    """
  end

  defp approved_receipts(receipts) do
    receipts
    |> Enum.filter(fn receipt -> receipt.is_approved end)
    # or remove :desc for ascending
    |> Enum.sort_by(& &1.receipt_date, {:desc, Date})
  end

  defp pending_receipts(receipts) do
    receipts
    |> Enum.filter(fn receipt -> receipt.is_approved == false end)
    |> Enum.sort_by(& &1.receipt_date, {:asc, Date})
  end
end
