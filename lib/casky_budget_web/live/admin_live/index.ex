defmodule CaskyBudgetWeb.AdminLive.Index do
  use CaskyBudgetWeb, :live_view

  def mount(params, session, socket) do
    socket =
      socket
      |> assign(:page_title, "Admin Dashboard")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>Hello</div>
    """
  end
end
