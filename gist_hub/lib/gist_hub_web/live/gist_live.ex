defmodule GistHubWeb.GistLive do
  use GistHubWeb, :live_view
  alias GistHub.Gists
  alias GistHubWeb.GistFormComponent
  alias GistHubWeb.Utils.{DateFormat, FormatUsername}

  @doc """
    Increment view count on second mount i.e. when WebSocket connection is established.
    See https://elixirforum.com/t/liveview-calls-mount-two-times/30519/4
  """
  def mount(params, session, socket) do
    case connected?(socket) do
      true ->
        Gists.increment_gist_views(params["id"])
        {:ok, socket}
      false ->
        {:ok, assign(socket, page: "loading")}
    end
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    gist = Gists.get_gist!(id)
    gist = Map.put(gist, :relative, DateFormat.get_relative_time(gist.updated_at))
    socket =
      assign(
        socket,
        gist: gist,
        show_form: false,
        page_title: gist.name
      )
    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    case Gists.delete_gist(socket.assigns.current_user, id) do
      {:ok, _gist} ->
        socket = put_flash(socket, :info, "Gist successfully deleted.")
        {:noreply, push_navigate(socket, to: ~p"/create")}
      {:error, :unauthorised} ->
        socket = put_flash(socket, :error, "Unauthorised.")
        {:noreply, socket}
      {:error, message} ->
        socket = put_flash(socket, :error, message)
        {:noreply, socket}
      _ ->
      {:noreply, socket}
    end
  end

  def handle_event("toggle_edit", _, socket) do
    socket = assign(socket, :show_form, true)
    {:noreply, socket}
  end
end
