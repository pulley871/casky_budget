defmodule CaskyBudgetWeb.AdminLive.Index do
  alias CaskyBudget.Admin
  use CaskyBudgetWeb, :live_view

  def mount(_params, _session, socket) do
    IO.inspect(self(), label: "MOUNT")

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    params =
      Map.put(params, "organization_id", socket.assigns.current_user.current_organization.id)

    socket =
      socket
      |> assign(:page_title, "Admin Dashboard")
      |> assign(:show_modal, false)
      |> assign(:selected_user, nil)
      |> assign(:form, to_form(params))
      |> stream(
        :users,
        Admin.search_for_user(params),
        limit: 20,
        reset: true
      )

    {:noreply, socket}
  end

  def handle_event("filter", form_params, socket) do
    form_params =
      form_params
      |> Map.take(~w(q))
      |> Map.reject(fn {_, value} -> value == "" end)

    socket =
      socket
      |> push_patch(to: ~p"/admin?#{form_params}")

    {:noreply, socket}
  end

  def handle_event("edit_user", %{"id" => user_id}, socket) do
    org_id = socket.assigns.current_user.current_organization.id

    user = Admin.get_user(user_id, org_id)

    socket =
      socket
      |> assign(:selected_user, user)
      |> update(:show_modal, &(!&1))

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="p-6">
      <div>Users</div>
      <.modal
        :if={@show_modal}
        id="update-user-role"
        title="Update Role"
        show={@show_modal}
        on_cancel={JS.patch(~p"/admin?#{@form.params}")}
      >
        <div class="space-y-4">
          <p>
            Please select the role you want to assign to the user
          </p>
          <%!-- <pre>{inspect(@form, pretty: true)}</pre> --%>
        </div>
      </.modal>
      <.form for={@form} phx-change="filter" id="filter-form" class="flex items-center gap-6">
        <.input field={@form[:q]} placeholder="Search..." autocomplete="off" />
        <.link patch={~p"/admin"}>
          Reset
        </.link>
      </.form>
      <.table id="users-list" rows={@streams.users} phx-update="stream">
        <:col :let={{_dom_id, user}} id="" label="Name">
          {user.first_name} {user.last_name}
        </:col>
        <:col :let={{_dom_id, user}} label="Phone number">
          {user.phone}
        </:col>
        <:col :let={{_dom_id, user}} label="Email">
          {user.email}
        </:col>
        <:col :let={{_dom_id, user}} label="Address">
          <div>
            <p class="text-sm">{user.address_line_one}</p>
            <p class="text-sm">{user.city} {user.state} {user.postal_code}</p>
          </div>
        </:col>
        <:col :let={{_dom_id, user}} label="Role">
          {user.role}
        </:col>
        <:action :let={{_dom_id, user}}>
          <.button phx-click="edit_user" phx-value-id={user.id}>Edit role</.button>
        </:action>
      </.table>
    </div>
    """
  end
end
