defmodule GistHubWeb.AllGistsLive do
  use GistHubWeb, :live_view
  alias GistHub.Gists
  alias Phoenix.LiveView.JS
  import GistHubWeb.GistComponent
  alias GistHubWeb.Utils.FormatUsername

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
