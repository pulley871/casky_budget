defmodule CaskyBudgetWeb.AdminLive.Index do
  use CaskyBudgetWeb, :live_view

  alias CaskyBudget.Admin

  @impl true
  def mount(_params, _session, socket) do
    IO.inspect(self(), label: "MOUNT")
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    organization_id = socket.assigns.current_user.current_organization.id
    params = Map.put(params, "organization_id", organization_id)

    socket =
      socket
      |> assign_defaults()
      |> assign(:form, to_form(params))
      |> assign(:update_user_form, to_form(%{}))
      |> stream(:users, Admin.search_for_user(params), limit: 20, reset: true)

    {:noreply, socket}
  end

  @impl true
  def handle_event("filter", form_params, socket) do
    sanitized_params =
      form_params
      |> Map.take(~w(q r))
      |> Map.reject(fn {_key, value} -> value == "" end)

    IO.inspect(sanitized_params)

    socket =
      socket
      |> push_patch(to: ~p"/admin?#{sanitized_params}")

    {:noreply, socket}
  end

  @impl true
  def handle_event("edit_user", %{"id" => user_id}, socket) do
    org_id = socket.assigns.current_user.current_organization.id
    user = Admin.get_user(user_id, org_id)

    form = to_form(%{"role" => Atom.to_string(user.role)})

    socket =
      socket
      |> assign(:selected_user, user)
      |> assign(:update_user_form, form)
      |> toggle_modal()

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate_role_change", %{"role" => _role} = params, socket) do
    socket =
      socket
      |> assign(:update_user_form, to_form(params))

    {:noreply, socket}
  end

  @impl true
  def handle_event("update_role", params, socket) do
    org_id = socket.assigns.current_user.current_organization.id
    role = String.to_atom(params["role"])

    case Admin.update_user_role(role, socket.assigns.selected_user, org_id) do
      {:ok, _updated_user} ->
        socket =
          socket
          |> stream_insert(:users, %{socket.assigns.selected_user | role: role}, at: 0)
          |> assign(:show_modal, false)
          |> put_flash(:info, "Successfully updated user's role.")

        hide_modal("update-user-role-modal")
        {:noreply, socket}

      {:error, _changeset} ->
        IO.inspect("Error updating role")
        {:noreply, socket}
    end
  end

  defp assign_defaults(socket) do
    socket
    |> assign(:page_title, "Admin Dashboard")
    |> assign(:show_modal, false)
    |> assign(:selected_user, nil)
  end

  defp toggle_modal(socket) do
    assign(socket, :show_modal, !socket.assigns.show_modal)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <h1>Users</h1>
      
    <!-- Modal -->
      <.modal
        :if={@show_modal}
        id="update-user-role-modal"
        title="Update Role"
        show={@show_modal}
        rounded="large"
      >
        <div class="space-y-4">
          <p>
            Update the role for user: {@selected_user.first_name} {@selected_user.last_name}
          </p>
          <.simple_form
            for={@update_user_form}
            class="flex flex-col gap-6"
            phx-change="validate_role_change"
            phx-submit="update_role"
            id="update-user-role-form"
          >
            <.input
              field={@update_user_form[:role]}
              prompt="Select Role"
              type="select"
              options={Admin.list_all_roles()}
            />
            <:actions>
              <.button disabled={
                @selected_user.role == String.to_existing_atom(@update_user_form.params["role"])
              }>
                Update Role
              </.button>
            </:actions>
          </.simple_form>
        </div>
      </.modal>
      
    <!-- Filter Form -->
      <.form for={@form} phx-change="filter" id="filter-form" class="flex items-center gap-6">
        <.input field={@form[:q]} placeholder="Search users..." autocomplete="off" />
        <.input field={@form[:r]} type="select" options={[:user, :admin]} />
        <.link patch={~p"/admin"}>Reset</.link>
      </.form>
      
    <!-- User Table -->
      <div phx-update="stream" id="users-list">
        <.table id="users-list" rows={@streams.users}>
          <:col :let={{_dom_id, user}} label="Name">
            {user.first_name} {user.last_name}
          </:col>
          <:col :let={{_dom_id, user}} label="Phone">
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
            <.button phx-click="edit_user" phx-value-id={user.id}>Edit Role</.button>
          </:action>
        </.table>
      </div>
    </div>
    """
  end
end
