defmodule GistHubWeb.SearchGistsLive do
  use GistHubWeb, :live_view
  alias GistHub.Gists
  alias GistHubWeb.Utils.{FormatUsername, FormatMarkup, DateFormat}

  def mount(_params, _session, socket) do
    socket = assign(
      socket,
      gists: [],
      search_term: "",
      form: to_form(%{"search_term" => ""}, as: "search_term"),
      page_title: "Search"
    )
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    socket =
      case params["query"] do
        query when query != "" and not is_nil(query) ->
          assign(
            socket,
            gists: Gists.search(query),
            search_term: query
          )
        _ ->
          socket
      end
    {:noreply, socket}
  end

  def handle_event("search", %{"search_term" => %{"search_term" => query}}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/search?#{[query: query]}")}
  end

  def render(assigns) do
    ~H"""
      <div class="gh-gradient">
        <div class="flex justify-center items-center py-6">
          <%= if @search_term == nil or @search_term == "" do %>
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="1.5"
              stroke="white"
              class="size-7"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M7.5 3.75H6A2.25 2.25 0 0 0 3.75 6v1.5M16.5 3.75H18A2.25 2.25 0 0 1 20.25 6v1.5m0 9V18A2.25 2.25 0 0 1 18 20.25h-1.5m-9 0H6A2.25 2.25 0 0 1 3.75 18v-1.5M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"
              />
            </svg>
            <h1 class="font-brand font-regular text-white text-3xl ml-2">
              Search more than 1M gists
            </h1>
          <% end %>
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
                  value={@search_term || ""}
                />
              </div>
              <div class="ml-4 mt-2">
                <.button class="create_button" phx-disable-with="Searching...">Search</.button>
              </div>
            </div>
          </.form>
        </div>
      </div>
      <%= if @gists do %>
        <div>
          <%= for {gist, index} <- Enum.with_index(@gists) do %>
            <.gist gist={gist} index={index} current_user={@current_user}/>
          <% end %>
        </div>
      <% end %>
    """
  end

  def gist(assigns) do
    ~H"""
    <div class="justify-center px-28 w-full mb-20">
      <div class="flex justify-between mb-2">
        <div class="flex items-center">
          <img
          src="/images/user-image.svg"
          alt="Profile Image"
          class="rounded-full w-6 h-6"
          >
          <div class="flex flex-col ml-4">
            <div class="text-base font-brand text-sm">
              <span class="text-white"><%= FormatUsername.strip_name_from_email(@gist.user.email) %></span>
              <span class="font-bold text-white">/</span>
              <.link
              href= {~p"/gist/?id=#{@gist.id}"}
              class="text-ghLavender-dark hover:underline"
              >
              <%= @gist.name %>
              </.link>
            </div>
            <div class="font-brand text-ghDark-light text-xs">
              <%=
               true
               && "Last active " <> DateFormat.get_relative_time(@gist.updated_at)
               || "Created " <> DateFormat.get_relative_time(@gist.inserted_at)
              %>
            </div>
            <p class="text-ghDark-light text-xs">
              <%= @gist.description %>
            </p>
          </div>
        </div>

        <div class="mr-8 px-3">
          <div class="flex items-center w-4">
            <img src="/images/comment.svg" alt="Comment Count">
            <span class="text-white h-6 px-1">0</span>
            <img src="/images/BookmarkOutline.svg" alt="Save Count">
            <span class="text-white h-6 px-1">0</span>
          </div>
        </div>
      </div>
        <div id={"gist-wrapper-#{@index}"} class="flex w-full" >
          <textarea id={"syntax-line-numbers-#{@index}"} class="all-syntax-numbers rounded-bl-md" readonly></textarea>
          <div id={"highlight-#{@index}"} class="all-syntax-area w-full rounded-br-md" phx-hook="Highlight" data-name={@gist.name} gist-index={@index}>
            <pre><code class="language-elixir"><%= FormatMarkup.get_preview_text(@gist.markup_text) %></code></pre>
          </div>
        </div>
    </div>
    """
  end
end
