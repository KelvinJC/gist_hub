defmodule GistHubWeb.GistLive do
  use GistHubWeb, :live_view
  alias GistHub.Gists

  def mount(%{"id" => id}, _session, socket) do
    gist = Gists.get_gist!(id)
    {:ok, assign(socket, gist: gist)}
  end
end
