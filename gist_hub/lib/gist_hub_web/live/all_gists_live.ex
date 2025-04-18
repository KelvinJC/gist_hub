defmodule GistHubWeb.AllGistsLive do
  use GistHubWeb, :live_view

  def mount(_params, _uri, socket) do
    {:ok, socket}
  end
end
