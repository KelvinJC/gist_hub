defmodule GistHubWeb.AllGistsLive do
  use GistHubWeb, :live_view
  alias GistHub.Gists
  alias GistHubWeb.Utils.{DateFormat, FormatUsername, FormatMarkup}
  alias Phoenix.LiveView.JS

  def mount(_params, _uri, socket) do
    socket = assign(
      socket,
      sort_button_text: "Recently updated",
      sort_by_updated_at: true,
      page_title: "Discover gists"
    )
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    socket =
      case params["sort_by"] do
        # validate url parameters
        sort_by when sort_by in ~w(recently_created_at least_recently_created_at recently_updated_at least_recently_updated_at) ->
          socket
          |> assign(
            sort_by: sort_by,
            sort_button_text: get_button_text(sort_by),
            sort_by_updated_at: String.contains?(sort_by, "updated")
          )
          |> push_event("sorted", %{}) # push event to client
        _ ->
          socket
      end
    {:noreply, load_gists(socket)}
  end

  def load_gists(socket) do
    sort_by =
      try do
        socket.assigns.sort_by
      rescue
        _ -> nil # catch `Key.Error` since :sort_by key not assigned yet
      end

    gists =
      case sort_by do
        "recently_updated_at" ->
          Gists.list_gists()
        nil ->
            Gists.list_gists()
        _ ->
          Gists.list_gists(sort_by)
      end

    assign(socket, gists: gists)
  end

  def gist(assigns) do
    ~H"""
    <div class="justify-center px-20 w-full mb-20">
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
               @sort_by_updated_at
               && "Last active " <> DateFormat.get_relative_time(@gist.updated_at)
               || "Created " <> DateFormat.get_relative_time(@gist.inserted_at)
              %>
            </div>
            <p class="text-ghDark-light text-xs">
              <%= @gist.description %>
            </p>
          </div>
        </div>
        <div class="px-3">
          <div class="flex items-center">
            <button class="mr-2" alt="Comment Count">
                <div class="flex justify-center items-center">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke-width="1.5"
                    stroke="gray"
                    class="size-4">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M7.5 8.25h9m-9 3H12m-9.75 1.51c0 1.6 1.123 2.994 2.707 3.227 1.129.166 2.27.293 3.423.379.35.026.67.21.865.501L12 21l2.755-4.133a1.14 1.14 0 0 1 .865-.501 48.172 48.172 0 0 0 3.423-.379c1.584-.233 2.707-1.626 2.707-3.228V6.741c0-1.602-1.123-2.995-2.707-3.228A48.394 48.394 0 0 0 12 3c-2.392 0-4.744.175-7.043.513C3.373 3.746 2.25 5.14 2.25 6.741v6.018Z" />
                  </svg>
                  <span class="text-ghDark-light text-xs h-5 px-1">0 comments</span>  
                </div>
            </button>
            <button class="mr-2" alt="Saves Count">
              <div class="flex justify-center items-center">
                <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="gray"
                class="size-4">
                <path stroke-linecap="round" stroke-linejoin="round" d="M17.593 3.322c1.1.128 1.907 1.077 1.907 2.185V21L12 17.25 4.5 21V5.507c0-1.108.806-2.057 1.907-2.185a48.507 48.507 0 0 1 11.186 0Z" />
              </svg>
              <span class="text-ghDark-light text-xs h-5 px-1">0 saves</span>              </div>
          </button>
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

  defp get_button_text(sort_type) when is_binary(sort_type) do
    case sort_type do
      "recently_updated_at" -> "Recently updated"
      "least_recently_updated_at" -> "Least recently updated"
      "recently_created_at" -> "Recently created"
      "least_recently_created_at" -> "Least recently created"
      _ -> "Recently updated"
    end
  end

  def toggle_sort_dropdown_menu do
    JS.toggle(
      to: "#sort_dropdown_menu",
      in: {"transition ease-out duration-100", "transform opacity-0 translate-y-[-10%]", "transform opacity-0 translate-y-0"},
      out: {"transition ease-in duration-75", "transform opacity-100 translate-y-0", "transform opacity-0 translate-y-[-10%]"}
      )
  end
end
