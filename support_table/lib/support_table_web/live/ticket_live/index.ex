defmodule SupportTableWeb.TicketLive.Index do
  use SupportTableWeb, :live_view
  alias SupportTable.Support.Ticket
  import Ash.Query

  @per_page 10

  @impl true
  def mount(_params, _session, socket) do
    representatives = SupportTable.Support.Representative |> Ash.read!()
    statuses = [:open, :closed]

    {:ok,
     socket
     |> assign(:representatives, representatives)
     |> assign(:statuses, statuses)
     |> assign(:search, "")
     |> assign(:status_filter, nil)
     |> assign(:representative_filter, nil)
     |> assign(:page, 1)
     |> assign(:per_page, @per_page)
     |> assign(:total_pages, 1)
     |> stream(:tickets, [])}
  end

  @impl true
  def handle_params(params, _url, socket) do
    page = String.to_integer(params["page"] || "1")
    {:noreply, socket |> assign(:page, page) |> apply_action(socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    {:noreply, socket |> assign(search: search, page: 1) |> fetch_tickets()}
  end

  def handle_event("filter_status", %{"status" => status}, socket) do
    {:noreply, socket |> assign(status_filter: status, page: 1) |> fetch_tickets()}
  end

  def handle_event("filter_representative", %{"representative" => representative_id}, socket) do
    {:noreply,
     socket |> assign(representative_filter: representative_id, page: 1) |> fetch_tickets()}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tickets")
    |> fetch_tickets()
  end

  defp fetch_tickets(socket) do
    %{
      search: search,
      status_filter: status_filter,
      representative_filter: representative_filter,
      page: page,
      per_page: per_page
    } = socket.assigns

    base_query =
      Ticket
      |> add_search_filter(search)
      |> add_status_filter(status_filter)
      |> add_representative_filter(representative_filter)

    query =
      base_query
      |> sort(inserted_at: :desc)
      |> load(:representative)
      |> limit(per_page)
      |> offset((page - 1) * per_page)

    case Ash.read(query) do
      {:ok, tickets} ->
        total_count = Ash.count!(base_query)
        total_pages = ceil(total_count / per_page)

        socket
        |> stream(:tickets, tickets, reset: true)
        |> assign(:total_pages, total_pages)

      {:error, error} ->
        socket
        |> put_flash(:error, "Error fetching tickets: #{inspect(error)}")
    end
  end

  defp add_search_filter(query, ""), do: query

  defp add_search_filter(query, search) do
    filter(query, ilike(subject, ^"%#{search}%"))
  end

  defp add_status_filter(query, nil), do: query

  defp add_status_filter(query, status) do
    filter(query, status == ^status)
  end

  defp add_representative_filter(query, nil), do: query

  defp add_representative_filter(query, "") do
    filter(query, is_nil(representative_id))
  end

  defp add_representative_filter(query, representative_id) do
    filter(query, representative_id == ^representative_id)
  end
end
