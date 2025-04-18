defmodule GistHubWeb.CreateGistLive do
  use GistHubWeb, :live_view
  alias GistHubWeb.GistFormComponent
  alias GistHub.{Gists, Gists.Gist}

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
      <div class="gh-gradient flex items-center justify-center">
        <h1 class="font-brand font-bold text-white text-3xl">
            Instantly share Elixir code, notes and snippets.
        </h1>
      </div>
      <.live_component
        module={GistFormComponent}
        form={to_form(Gists.change_gist(%Gist{}))}
        id={:new}
        current_user={@current_user}
      />
    """
  end
end
