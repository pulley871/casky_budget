defmodule CaskyBudgetWeb.OrganizationUsersLive.Index do
  alias CaskyBudget.Accounts
  use CaskyBudgetWeb, :live_view

  def mount(_params, _session, socket) do
    users = Accounts.get_organization_users(socket.assigns.current_user.current_organization.id)

    socket =
      socket
      |> assign(:page_title, "Organization Users")
      |> assign_async(:users, fn ->
        {:ok,
         %{
           users: users
         }}
      end)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="body-container">
      <h1 class="text-lg font-bold">Users</h1>
      <.async_result :let={users} assign={@users}>
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
        <%!-- <pre>{inspect(users, pretty: true)}</pre>  --%>
        <.table id="users-table" rows={users}>
          <:col :let={user} label="Name">{"#{user.first_name} #{user.last_name}"}</:col>
          <:col :let={user} label="Email">{user.email}</:col>
          <:col :let={user} label="Phone">{user.phone}</:col>
          <:col :let={user} label="Total receipts">{user.receipt_count}</:col>
          <:col :let={user} label="Approved receipts">{user.approved_receipts}</:col>
          <:col :let={user} label="Pending receipts">{user.pending_receipts}</:col>
          <:col :let={user} label="Receipts awaiting payment">{user.receipts_awaiting_payment}</:col>

          <:action>
            <.button phx-click="go" class="bg-none p-0">
              <.icon name="hero-trash" class="h-6 w-6 text-white hover:text-red-500" />
            </.button>
          </:action>
          <:action>
            <.button phx-click="go" class="bg-none hover:bg-none">
              <.icon name="hero-pencil-square" class="h-6 w-6 text-white hover:text-blue-500" />
            </.button>
          </:action>
        </.table>
      </.async_result>
    </div>
    """
  end
end
