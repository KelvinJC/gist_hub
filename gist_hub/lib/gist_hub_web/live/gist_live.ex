defmodule GistHubWeb.GistLive do
  use GistHubWeb, :live_view

  def mount(params, _session, socket) do
    {:ok, socket}
  end
end
