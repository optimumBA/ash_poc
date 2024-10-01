defmodule AnkraWeb.CustomerLive.Index do
  use AnkraWeb, :live_view

  alias Ankra.Customers
  alias Ankra.Customers.Customer

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.header>
      Listing Customers
      <:actions>
        <.link patch={~p"/customers/new"}>
          <.button>New Customer</.button>
        </.link>

        <.dropdown label="Filter by Status" class="ml-2">
          <.dropdown_menu_item
            :for={status <- Ash.Resource.Info.attribute(Customer, :status).constraints[:one_of]}
            link_type="a"
            to={~p"/?status=#{status}"}
            label={status |> Atom.to_string() |> String.capitalize()}
          />
        </.dropdown>
      </:actions>
    </.header>

    <.table
      id="customers"
      rows={@streams.customers}
      row_click={fn {_id, customer} -> JS.navigate(~p"/customers/#{customer}") end}
    >
      <:col :let={{_id, customer}} label="Email"><%= customer.email %></:col>

      <:col :let={{_id, customer}} label="Name"><%= customer.full_name %></:col>

      <:col :let={{_id, customer}} label="Phone number"><%= customer.phone_number %></:col>

      <:col :let={{_id, customer}} label="Role"><%= customer.role %></:col>

      <:col :let={{_id, customer}} label="Status">
        <.badge
          color={assign_color(customer.status)}
          label={customer.status |> Atom.to_string() |> String.capitalize()}
        />
      </:col>

      <:action :let={{_id, customer}}>
        <div class="sr-only">
          <.link navigate={~p"/customers/#{customer}"}>Show</.link>
        </div>
        <.link
          patch={~p"/customers/#{customer}/edit"}
          class={
            if(Ash.can?({customer, :update}, @current_user),
              do: "text-green-400",
              else: "text-gray-400 pointer-events-none cursor-not-allowed"
            )
          }
        >
          Edit
        </.link>
      </:action>

      <:action :let={{id, customer}} :if={Ash.can?({Customer, :destroy}, @current_user)}>
        <.link
          phx-click={JS.push("delete", value: %{id: customer.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal :if={@live_action in [:new, :edit]} id="customer-modal" show on_cancel={JS.patch(~p"/")}>
      <.live_component
        module={AnkraWeb.CustomerLive.FormComponent}
        id={(@customer && @customer.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        customer={@customer}
        patch={~p"/"}
      />
    </.modal>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    filters = %{}

    {:ok,
     socket
     |> stream(:customers, [], reset: true)
     |> assign(:filters, filters)
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Customer")
    |> assign(
      :customer,
      Ash.get!(Customer, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Customer")
    |> assign(:customer, nil)
  end

  defp apply_action(socket, :index, %{"status" => status}) do
    status = String.to_atom(status)

    socket
    |> assign(:filters, %{status: status})
    |> stream(
      :customers,
      Customers.list_customers!(%{status: status}, actor: socket.assigns[:current_user]),
      reset: true
    )
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> stream(
       :customers,
       Customers.list_customers!(socket.assigns.filters, actor: socket.assigns[:current_user]),
       reset: true
     )
    |> assign(:page_title, "Listing Customers")
    |> assign(:customer, nil)
  end

  @impl Phoenix.LiveView
  def handle_info({AnkraWeb.CustomerLive.FormComponent, {:saved, customer}}, socket) do
    {:noreply, stream_insert(socket, :customers, customer)}
  end

  @impl Phoenix.LiveView
  def handle_event("delete", %{"id" => id}, socket) do
    customer = Ash.get!(Ankra.Customers.Customer, id, actor: socket.assigns.current_user)
    Ash.destroy!(customer, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :customers, customer)}
  end

  defp assign_color(status) do
    %{
      active: "success",
      pending: "gray",
      cancelled: "danger"
    }[status]
  end
end
