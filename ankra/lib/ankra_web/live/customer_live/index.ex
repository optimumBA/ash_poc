defmodule AnkraWeb.CustomerLive.Index do
  use AnkraWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Customers
      <:actions>
        <.link patch={~p"/customers/new"}>
          <.button>New Customer</.button>
        </.link>
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

      <:action :let={{_id, customer}}>
        <div class="sr-only">
          <.link navigate={~p"/customers/#{customer}"}>Show</.link>
        </div>

        <.link patch={~p"/customers/#{customer}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, customer}}>
        <.link
          phx-click={JS.push("delete", value: %{id: customer.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="customer-modal"
      show
      on_cancel={JS.patch(~p"/")}
    >
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

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :customers,
       Ash.read!(Ankra.Customers.Customer, actor: socket.assigns[:current_user], load: [:full_name])
     )
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Customer")
    |> assign(
      :customer,
      Ash.get!(Ankra.Customers.Customer, id, actor: socket.assigns.current_user)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Customer")
    |> assign(:customer, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Customers")
    |> assign(:customer, nil)
  end

  @impl true
  def handle_info({AnkraWeb.CustomerLive.FormComponent, {:saved, customer}}, socket) do
    {:noreply, stream_insert(socket, :customers, customer)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    customer = Ash.get!(Ankra.Customers.Customer, id, actor: socket.assigns.current_user)
    Ash.destroy!(customer, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :customers, customer)}
  end
end
