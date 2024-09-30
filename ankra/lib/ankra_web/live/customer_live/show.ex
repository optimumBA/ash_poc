defmodule AnkraWeb.CustomerLive.Show do
  use AnkraWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <%= @customer.full_name %>

      <:actions :if={Ash.can?({@customer, :update}, @current_user)}>
        <.link patch={~p"/customers/#{@customer}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit customer</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Email"><%= @customer.email %></:item>

      <:item title="Phone number"><%= @customer.phone_number %></:item>

      <:item title="Role"><%= @customer.role %></:item>

      <:item title="Status"><%= @customer.status |> Atom.to_string() |> String.capitalize() %></:item>
    </.list>

    <.back navigate={~p"/"}>Back to customers</.back>

    <.modal
      :if={@live_action == :edit}
      id="customer-modal"
      show
      on_cancel={JS.patch(~p"/customers/#{@customer}")}
    >
      <.live_component
        module={AnkraWeb.CustomerLive.FormComponent}
        id={@customer.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        customer={@customer}
        patch={~p"/customers/#{@customer}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(
       :customer,
       Ash.get!(Ankra.Customers.Customer, id,
         actor: socket.assigns.current_user,
         load: [:full_name]
       )
     )}
  end

  defp page_title(:show), do: "Show Customer"
  defp page_title(:edit), do: "Edit Customer"
end
