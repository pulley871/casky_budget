defmodule CaskyBudgetWeb.ReceiptLive.Form do
  alias CaskyBudget.Budgets.Receipt
  alias CaskyBudget.Budgets
  use CaskyBudgetWeb, :live_view

  def mount(params, _session, socket) do
    {:ok, handle_action(socket.assigns.live_action, params, socket)}
  end

  defp handle_action(:new, _params, socket) do
    incident = %Receipt{}
    changeset = Budgets.change_receipt(incident)

    socket
    |> assign(:page_title, "New Incident Form")
    |> assign(:form, to_form(changeset))
    # |> allow_upload(:photo, accept: ~w(.png, .jpeg, .pdf), max_entries: 1, auto_upload: true)
    |> assign(:incident, incident)
  end

  defp handle_action(:edit, %{"id" => id}, socket) do
    # incident = Receipt.get(id)
    # changeset = Admin.change_incident(incident)

    socket
    |> assign(:page_title, "Edit Incident")

    # |> assign(:form, to_form(changeset))
    # |> assign(:incident, incident)
  end

  def render(assigns) do
    ~H"""
    <.simple_form for={@form} id="receipt-form">
      <.input label="Place of purchase" field={@form[:business_name]} />
      <.input
        type="select"
        name="personal-payment"
        label="Were personal funds used to for this?"
        options={[{"Yes", "true"}, {"No", "false"}]}
        selected="false"
        field={@form[:is_personal_payment]}
      />
      <%!-- <.input label="Upload receipt" field={@form[:receipt]} type="file" /> --%>
    </.simple_form>
    """
  end
end
