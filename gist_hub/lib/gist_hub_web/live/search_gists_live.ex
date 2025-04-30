defmodule GistHubWeb.SearchGistsLive do
  use GistHubWeb, :live_view
  alias GistHub.Gists

  def mount(_params, _session, socket) do
    socket = assign(
      socket, 
      search: false,
      form: to_form(%{"search_term" => ""}, as: "search_term"),
      page_title: "Search"
    )
    {:ok, socket}
  end

  def handle_event("search", %{"search_term" => search_term}, socket) do
  end

  def render(assigns) do
    ~H"""
      <div class="gh-gradient flex items-center justify-center">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="white" class="size-7">
            <path stroke-linecap="round" stroke-linejoin="round" d="M7.5 3.75H6A2.25 2.25 0 0 0 3.75 6v1.5M16.5 3.75H18A2.25 2.25 0 0 1 20.25 6v1.5m0 9V18A2.25 2.25 0 0 1 18 20.25h-1.5m-9 0H6A2.25 2.25 0 0 1 3.75 18v-1.5M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
          </svg>
          <h1 class="font-brand font-regular text-white text-3xl ml-2">
            Search more than 1M gists
          </h1>
      </div>
      <div id="search_form" phx-hook="RemoveHeaderSearchBar" class="mx-auto mb-40">
        <.form for={@form} phx-submit="search">
          <div class="flex justify-center items-center px-28">
            <div class="w-full">
              <.input
                type="text"
                field={@form[:search_term]}
                placeholder="Search..."
                autocomplete="off"
            />
            </div>
            <div class="ml-4 mt-2">
              <.button class="create_button" phx-disable-with="Searching...">Search</.button>
            </div>
          </div>
        </.form>
      </div>
    """
  end
end
