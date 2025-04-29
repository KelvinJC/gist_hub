defmodule GistHubWeb.SearchGistsLive do
  use GistHubWeb, :live_view
  alias GistHub.Gists

  def mount(_params, _session, socket) do
    socket = assign(socket, search: false)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <div class="gh-gradient flex">
        <div class="flex justify-between w-full px-20 mt-4 mb-2">
          <span class="flex py-2">
            <h1>
              <span class="font-brand text-m text-white mr-2">
                <%= if @search do %>
                  Search Results.
                <% else %>
                  No search results available.
                <% end %>
              </span>
            </h1>
          </span>
        </div>
      </div>
    """
  end
end
