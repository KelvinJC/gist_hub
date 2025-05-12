defmodule GistHubWeb.GistLive do
  use GistHubWeb, :live_view
  alias GistHub.Gists
  alias GistHubWeb.GistFormComponent
  alias GistHubWeb.Utils.{DateFormat, FormatUsername}
  alias GistHubWeb.GistNotFound

  @doc """
    Increment view count on second mount i.e. when WebSocket connection is established.
    See https://elixirforum.com/t/liveview-calls-mount-two-times/30519/4
  """
  def mount(params, _session, socket) do
    with true <- connected?(socket),
        id = params["gist_id"],
        {:ok, valid_uuid} <- Ecto.UUID.cast(id) do
      Gists.increment_gist_views(id)
      {:ok, socket}
    else
      false ->
        {:ok, assign(socket, page: "loading")}
      :error ->
        raise GistNotFound, "unknown gist #{inspect(params["gist_id"])}"
    end
  end

  def handle_params(%{"gist_id" => id}, _uri, socket) do
    case Ecto.UUID.cast(id) do
      {:ok, valid_uuid} ->
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
      :error ->
        raise GistNotFound, "unknown gist #{inspect(id)}"
    end
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

defmodule GistHubWeb.GistNotFound do
  @moduledoc false
  defexception [:message, plug_status: 404]
end
