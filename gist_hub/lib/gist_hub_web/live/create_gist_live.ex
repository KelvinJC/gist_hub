defmodule GistHubWeb.CreateGistLive do
  use GistHubWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
