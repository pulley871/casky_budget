defmodule CaskyBudgetWeb.Components.Sidebar do
  @moduledoc """
  The `MusicCentralWeb.Components.Sidebar` module provides a versatile and customizable sidebar
  component for Phoenix LiveView applications. This component is designed to create a
  navigation or information panel that can be toggled in and out of view, enhancing the user
  experience by offering easy access to additional content or navigation links.

  The component supports various configuration options, such as color themes, border styles,
  size, and positioning. It also allows developers to control the visibility and behavior of
  the sidebar through custom JavaScript actions. The sidebar can be positioned on either side of
  the screen, and it includes options for different visual variants, such as shadowed or transparent styles.

  The `Sidebar` component is ideal for building dynamic user interfaces that require collapsible
  navigation or content panels, and it integrates seamlessly with other Phoenix LiveView components
  for a cohesive and interactive application experience.
  """
  use Phoenix.Component
  use Gettext, backend: CaskyBudgetWeb.Gettext
  alias Phoenix.LiveView.JS

  @colors [
    "white",
    "primary",
    "secondary",
    "dark",
    "success",
    "warning",
    "danger",
    "info",
    "light",
    "misc",
    "dawn"
  ]

  @variants [
    "default",
    "outline",
    "transparent",
    "shadow",
    "unbordered"
  ]

  @doc """
  Renders a `sidebar` component that can be shown or hidden based on user interactions.

  The sidebar supports various customizations such as size, color theme, and border style.

  ## Examples

  ```elixir
  <.sidebar id="left" size="extra_small" color="dark" hide_position="left">
    <div class="px-4 py-2">
      <h2 class="text-white">Menu</h2>
      ...
    </div>
  </.sidebar>
  ```
  """
  @doc type: :component
  attr :id, :string,
    required: true,
    doc: "A unique identifier is used to manage state and interaction"

  attr :variant, :string, values: @variants, default: "default", doc: "Determines the style"
  attr :color, :string, values: @colors, default: "white", doc: "Determines color theme"

  attr :size, :string,
    default: "large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :border, :string, default: "extra_small", doc: "Determines border style"
  attr :position, :string, default: "start", doc: "Determines the element position"

  attr :hide_position, :string,
    values: ["left", "right"],
    doc: "Determines what position should be hidden"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :on_hide, JS, default: %JS{}, doc: "Custom JS module for on_hide action"
  attr :on_show, JS, default: %JS{}, doc: "Custom JS module for on_show action"
  attr :on_hide_away, JS, default: %JS{}, doc: "Custom JS module for on_hide_away action"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  @spec sidebar(map()) :: Phoenix.LiveView.Rendered.t()
  def sidebar(assigns) do
    ~H"""
    <aside
      id={@id}
      phx-click-away={hide_sidebar(@on_hide_away, @id, @hide_position)}
      phx-remove={hide_sidebar(@id, @hide_position)}
      class={[
        "fixed h-screen transition-transform z-10",
        border_class(@border, @position),
        hide_position(@hide_position),
        color_variant(@variant, @color),
        position_class(@position),
        size_class(@size),
        @class
      ]}
      aria-label="Sidebar"
      {@rest}
    >
      <div class="h-full overflow-y-auto">
        <div class="flex justify-end pt-2 px-2 mb-1 md:hidden dismiss-sidebar-wrapper">
          <button
            type="button"
            class="dismiss-sidebar-button"
            phx-click={JS.exec(@on_hide, "phx-remove", to: "##{@id}")}
          >
            <.icon name="hero-x-mark" />
            <span class="sr-only">{gettext("Close menu")}</span>
          </button>
        </div>
        {render_slot(@inner_block)}
      </div>
    </aside>
    """
  end

  @doc """
  Shows the sidebar by applying specific CSS classes to animate it onto the screen.

  ## Parameters

    - `js`: A `Phoenix.LiveView.JS` struct used for managing client-side JavaScript interactions. Defaults to an empty `%JS{}`.
    - `id`: A unique identifier (string) for the sidebar element to be shown. This should correspond to the `id` attribute of the sidebar HTML element.
    - `position`: A string representing the initial position of the sidebar when hidden. Valid values include `"left"` or `"right"`, indicating whether the sidebar is off-screen to the left or right.

  ## Returns

    - Returns an updated `Phoenix.LiveView.JS` struct with the appropriate class changes applied to show the sidebar.

  ## Example

    ```elixir
    show_sidebar(%JS{}, "sidebar-id", "right")
    ```
  This will show the sidebar with the ID "sidebar-id" by sliding it onto the screen from the right.
  """

  def show_sidebar(js \\ %JS{}, id, position) when is_binary(id) do
    JS.remove_class(js, hide_position(position), to: "##{id}")
    |> JS.add_class("transform-none", to: "##{id}")
  end

  @doc """
  Hides the sidebar by applying specific CSS classes to animate it off-screen.

  ## Parameters

    - `js`: A `Phoenix.LiveView.JS` struct used for managing client-side JavaScript interactions. Defaults to an empty `%JS{}`.
    - `id`: A unique identifier (string) for the sidebar element to be hidden. The ID should correspond to the `id` attribute of the sidebar HTML element.
    - `position`: A string representing the direction in which the sidebar should be hidden. Valid values include `"left"` or `"right"`, indicating whether the sidebar will slide off the screen to the left or right, respectively.

  ## Returns

    - Returns an updated `Phoenix.LiveView.JS` struct with the appropriate class changes applied to hide the sidebar.

  ## Example

    ```elixir
    hide_sidebar(%JS{}, "sidebar-id", "left")
    ```

  This will hide the sidebar with the ID "sidebar-id" by sliding it off-screen to the left.
  """

  def hide_sidebar(js \\ %JS{}, id, position) do
    JS.remove_class(js, "transform-none", to: "##{id}")
    |> JS.add_class(hide_position(position), to: "##{id}")
  end

  defp hide_position("left"), do: "-translate-x-full md:translate-x-0"
  defp hide_position("right"), do: "translate-x-full md:translate-x-0"
  defp hide_position(_), do: nil

  defp position_class("start"), do: "top-0 start-0"
  defp position_class("end"), do: "top-0 end-0"
  defp position_class(params) when is_binary(params), do: params
  defp position_class(_), do: position_class("start")

  defp border_class("none", _), do: "border-0"
  defp border_class("extra_small", "start"), do: "border-e"
  defp border_class("small", "start"), do: "border-e-2"
  defp border_class("medium", "start"), do: "border-e-[3px]"
  defp border_class("large", "start"), do: "border-e-4"
  defp border_class("extra_large", "start"), do: "border-e-[5px]"

  defp border_class("extra_small", "end"), do: "border-s"
  defp border_class("small", "end"), do: "border-s-2"
  defp border_class("medium", "end"), do: "border-s-[3px]"
  defp border_class("large", "end"), do: "border-s-4"
  defp border_class("extra_large", "end"), do: "border-s-[5px]"

  defp border_class(params, _) when is_binary(params), do: params
  defp border_class(_, _), do: border_class("extra_small", "start")

  defp size_class("extra_small"), do: "w-60"

  defp size_class("small"), do: "w-64"

  defp size_class("medium"), do: "w-72"

  defp size_class("large"), do: "w-80"

  defp size_class("extra_large"), do: "w-96"

  defp size_class(params) when is_binary(params), do: params

  defp size_class(_), do: size_class("large")

  defp color_variant("default", "white") do
    "bg-white text-[#3E3E3E] border-[#DADADA]"
  end

  defp color_variant("default", "primary") do
    "bg-[#4363EC] text-white border-[#2441de]"
  end

  defp color_variant("default", "secondary") do
    "bg-[#6B6E7C] text-white border-[#877C7C]"
  end

  defp color_variant("default", "success") do
    "bg-[#ECFEF3] text-[#047857] border-[#6EE7B7]"
  end

  defp color_variant("default", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-[#FF8B08]"
  end

  defp color_variant("default", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-[#E73B3B]"
  end

  defp color_variant("default", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-[#004FC4]"
  end

  defp color_variant("default", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-[#52059C]"
  end

  defp color_variant("default", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-[#4D4137]"
  end

  defp color_variant("default", "light") do
    "bg-[#E3E7F1] text-[#707483] border-[#707483]"
  end

  defp color_variant("default", "dark") do
    "bg-[#1E1E1E] text-white border-[#050404]"
  end

  defp color_variant("outline", "white") do
    "bg-transparent text-white border-white"
  end

  defp color_variant("outline", "primary") do
    "bg-transparent text-[#4363EC] border-[#4363EC] "
  end

  defp color_variant("outline", "secondary") do
    "bg-transparent text-[#6B6E7C] border-[#6B6E7C]"
  end

  defp color_variant("outline", "success") do
    "bg-transparent text-[#227A52] border-[#6EE7B7]"
  end

  defp color_variant("outline", "warning") do
    "bg-transparent text-[#FF8B08] border-[#FF8B08]"
  end

  defp color_variant("outline", "danger") do
    "bg-transparent text-[#E73B3B] border-[#E73B3B]"
  end

  defp color_variant("outline", "info") do
    "bg-transparent text-[#004FC4] border-[#004FC4]"
  end

  defp color_variant("outline", "misc") do
    "bg-transparent text-[#52059C] border-[#52059C]"
  end

  defp color_variant("outline", "dawn") do
    "bg-transparent text-[#4D4137] border-[#4D4137]"
  end

  defp color_variant("outline", "light") do
    "bg-transparent text-[#707483] border-[#707483]"
  end

  defp color_variant("outline", "dark") do
    "bg-transparent text-[#1E1E1E] border-[#1E1E1E]"
  end

  defp color_variant("unbordered", "white") do
    "bg-white text-[#3E3E3E] border-transparent"
  end

  defp color_variant("unbordered", "primary") do
    "bg-[#4363EC] text-white border-transparent"
  end

  defp color_variant("unbordered", "secondary") do
    "bg-[#6B6E7C] text-white border-transparent"
  end

  defp color_variant("unbordered", "success") do
    "bg-[#ECFEF3] text-[#047857] border-transparent"
  end

  defp color_variant("unbordered", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-transparent"
  end

  defp color_variant("unbordered", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-transparent"
  end

  defp color_variant("unbordered", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-transparent"
  end

  defp color_variant("unbordered", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-transparent"
  end

  defp color_variant("unbordered", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-transparent"
  end

  defp color_variant("unbordered", "light") do
    "bg-[#E3E7F1] text-[#707483] border-transparent"
  end

  defp color_variant("unbordered", "dark") do
    "bg-[#1E1E1E] text-white border-transparent"
  end

  defp color_variant("shadow", "white") do
    "bg-white text-[#3E3E3E] border-[#DADADA] shadow-md"
  end

  defp color_variant("shadow", "primary") do
    "bg-[#4363EC] text-white border-[#4363EC] shadow-md"
  end

  defp color_variant("shadow", "secondary") do
    "bg-[#6B6E7C] text-white border-[#6B6E7C] shadow-md"
  end

  defp color_variant("shadow", "success") do
    "bg-[#AFEAD0] text-[#227A52] border-[#AFEAD0] shadow-md"
  end

  defp color_variant("shadow", "warning") do
    "bg-[#FFF8E6] text-[#FF8B08] border-[#FFF8E6] shadow-md"
  end

  defp color_variant("shadow", "danger") do
    "bg-[#FFE6E6] text-[#E73B3B] border-[#FFE6E6] shadow-md"
  end

  defp color_variant("shadow", "info") do
    "bg-[#E5F0FF] text-[#004FC4] border-[#E5F0FF] shadow-md"
  end

  defp color_variant("shadow", "misc") do
    "bg-[#FFE6FF] text-[#52059C] border-[#FFE6FF] shadow-md"
  end

  defp color_variant("shadow", "dawn") do
    "bg-[#FFECDA] text-[#4D4137] border-[#FFECDA] shadow-md"
  end

  defp color_variant("shadow", "light") do
    "bg-[#E3E7F1] text-[#707483] border-[#E3E7F1] shadow-md"
  end

  defp color_variant("shadow", "dark") do
    "bg-[#1E1E1E] text-white border-[#1E1E1E] shadow-md"
  end

  defp color_variant("transparent", "white") do
    "bg-transparent text-white border-transparent"
  end

  defp color_variant("transparent", "primary") do
    "bg-transparent text-[#4363EC] border-transparent"
  end

  defp color_variant("transparent", "secondary") do
    "bg-transparent text-[#6B6E7C] border-transparent"
  end

  defp color_variant("transparent", "success") do
    "bg-transparent text-[#227A52] border-transparent"
  end

  defp color_variant("transparent", "warning") do
    "bg-transparent text-[#FF8B08] border-transparent"
  end

  defp color_variant("transparent", "danger") do
    "bg-transparent text-[#E73B3B] border-transparent"
  end

  defp color_variant("transparent", "info") do
    "bg-transparent text-[#6663FD] border-transparent"
  end

  defp color_variant("transparent", "misc") do
    "bg-transparent text-[#52059C] border-transparent"
  end

  defp color_variant("transparent", "dawn") do
    "bg-transparent text-[#4D4137] border-transparent"
  end

  defp color_variant("transparent", "light") do
    "bg-transparent text-[#707483] border-transparent"
  end

  defp color_variant("transparent", "dark") do
    "bg-transparent text-[#1E1E1E] border-transparent"
  end

  attr :name, :string, required: true, doc: "Specifies the name of the element"
  attr :class, :any, default: nil, doc: "Custom CSS class for additional styling"

  defp icon(%{name: "hero-" <> _, class: class} = assigns) when is_list(class) do
    ~H"""
    <span class={[@name] ++ @class} />
    """
  end

  defp icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end
end
