defmodule GistHubWeb.SearchBarComponent do
  use GistHubWeb, :live_component
  alias GistHub.Gists

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <%= if @form do %>
        <.form for={@form} phx-submit="search" phx-target={@myself}>
        <div class="flex mr-2">
          <input
            type="text"
            class="rounded-l-lg bg-ghDark-dark border-white py-1
              focus:outline-none focus:border-ghLavender focus:ring-0
              placeholder-ghDark-light text-white text-sm font-brand font-regular "
            placeholder="Search..."
            id={@form[:search_term].id}
            name={@form[:search_term].name}
            value={@form[:search_term].value}
          />
          <button
            phx-disable-with="."
            class="rounded-r-lg bg-ghDark-dark border-r border-b border-t border-white px-2
              focus:outline-none focus:border-ghLavender focus:ring-0"
          >
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.0" stroke="gray" class="size-4">
              <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
            </svg>
          </button>
        </div>
        </.form>
      <% end %>
    </div>
    """
  end

  def handle_event("search", %{"search_term" => search_term}, socket) do
    gists = Gists.search_gists(search_term)
    {:noreply, socket}
  end
end
