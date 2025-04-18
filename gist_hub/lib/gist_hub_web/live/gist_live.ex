defmodule GistHubWeb.GistLive do
  use GistHubWeb, :live_view
  use Timex
  alias GistHub.Gists
  alias GistHubWeb.GistFormComponent

  def mount(%{"id" => id}, _session, socket) do
    gist = Gists.get_gist!(id)
    {:ok, relative_time} = Timex.format(gist.updated_at, "{relative}", :relative)
    gist = Map.put(gist, :relative, relative_time)
    socket_updated =
      socket
      |> assign(gist: gist)
      |> assign(show_form: false)
    {:ok, socket_updated}
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
