defmodule GistHubWeb.CreateGistLive do
  use GistHubWeb, :live_view
  alias GistHubWeb.GistFormComponent
  alias GistHub.{Gists, Gists.Gist}

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Create a new gist")}
  end

  def render(assigns) do
    ~H"""
      <div class="gradientBg">
        <div class="flex items-center justify-center">
          <div class="mt-20 mb-10">
            <h1 class="font-brand text-white text-xl">
              Instantly share code, notes and snippets.
            </h1>
          </div>
        </div>
        <.live_component
          module={GistFormComponent}
          form={to_form(Gists.change_gist(%Gist{}))}
          id={:new}
          current_user={@current_user}
        />
      </div>
    """
  end
end
