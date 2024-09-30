defmodule AnkraWeb.CustomerLive.FormComponent do
  use AnkraWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="customer-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:email]} type="text" label="Email" />

        <.input field={@form[:first_name]} type="text" label="First name" />

        <.input field={@form[:last_name]} type="text" label="Last name" />

        <.input field={@form[:phone_number]} type="text" label="Phone number" />

        <.input field={@form[:role]} type="text" label="Role" />
        <.input
          field={@form[:status]}
          type="select"
          label="Status"
          options={
            Ash.Resource.Info.attribute(Ankra.Customers.Customer, :status).constraints[:one_of]
          }
        />
        <.input field={@form[:avatar]} type="text" label="Avatar" />

        <:actions>
          <.button phx-disable-with="Saving...">Save Customer</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"customer" => customer_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, customer_params))}
  end

  def handle_event("save", %{"customer" => customer_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: customer_params) do
      {:ok, customer} ->
        notify_parent({:saved, customer})

        socket =
          socket
          |> put_flash(:info, "Customer #{socket.assigns.form.source.type}d successfully")
          |> push_navigate(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{customer: customer}} = socket) do
    form =
      if customer do
        AshPhoenix.Form.for_update(customer, :update,
          as: "customer",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Ankra.Customers.Customer, :create,
          as: "customer",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end
end
