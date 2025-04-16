defmodule GistHubWeb.GistLive do
  use GistHubWeb, :live_view
  alias GistHub.Gists

  def mount(%{"id" => id}, _session, socket) do
    gist = Gists.get_gist!(id)
    {:ok, assign(socket, gist: gist)}
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
end
