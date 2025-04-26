defmodule GistHubWeb.AllGistsLive do
  use GistHubWeb, :live_view
  alias GistHub.Gists
  alias GistHubWeb.Utils.{DateFormat, FormatUsername}
  alias Phoenix.LiveView.JS

  def mount(_params, _uri, socket) do
    socket = assign(
      socket,
      sort_button_text: "Recently updated",
      sort_by_updated_at: true
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
            <pre><code class="language-elixir"><%= get_preview_text(@gist.markup_text) %></code></pre>
          </div>
        </div>
    </div>
    """
  end

  defp get_preview_text(markup_text) when not is_nil(markup_text) do
    lines =
      markup_text
      |> String.trim()
      |> String.split("\n")
      if length(lines) > 10 do
        Enum.take(lines, 10)
        |> Enum.join("\n")
      else
        markup_text
      end
  end

  defp get_preview_text(_), do: ""

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
