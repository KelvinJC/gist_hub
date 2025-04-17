defmodule GistHubWeb.CreateGistLive do
  use GistHubWeb, :live_view
  alias GistHubWeb.GistFormComponent
  alias GistHub.{Gists, Gists.Gist}

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
