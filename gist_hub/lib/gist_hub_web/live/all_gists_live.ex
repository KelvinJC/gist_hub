defmodule GistHubWeb.AllGistsLive do
  use GistHubWeb, :live_view
  alias GistHub.Gists
  alias GistHubWeb.Utils.DateFormat

  def mount(_params, _uri, socket) do
    {:ok, socket}
  end

  def handle_params(_params, _uri, socket) do
    gists = Gists.list_gists()
    socket =
      assign(
        socket,
        gists: gists
      )
    {:noreply, socket}
  end

  def gist(assigns) do
    ~H"""
    <div class="justify-center px-20 w-full mb-20">
      <div class="flex justify-between mb-2">
        <div class="flex items-center">
          <img
          src="/images/user-image.svg"
          alt="Profile Image"
          class="rounded-full w-6 h-6"
          >
          <div class="flex flex-col ml-4">
            <div class="font-bold text-base text-ghLavender-dark">
              <%= @gist.id %> <span class="text-white">/</span>
              <.link
              href= {~p"/gist/?id=#{@gist.id}"}
              class="hover:underline"
              >
              <%= @gist.name %>
              </.link>
            </div>
            <div class="font-bold text-white text-lg">
              <%= DateFormat.get_relative_time(@gist.updated_at) %>
            </div>
            <p class="text-white text-sm">
              <%= @gist.description %>
            </p>
          </div>
        </div>
        <div class="flex items-center">
          <img src="/images/comment.svg" alt="Comment Count">
          <span class="text-white h-6 px-1">0</span>
          <img src="/images/BookmarkOutline.svg" alt="Save Count">
          <span class="text-white h-6 px-1">0</span>
        </div>
      </div>
        <div id="gist-wrapper" class="flex w-full" phx-hook="TrimAllCodeBlocks">
          <textarea id="syntax-line-numbers" class="all-syntax-numbers rounded-bl-md" readonly></textarea>
          <div id="highlight" class="all-syntax-area w-full rounded-br-md" phx-hook="Highlight" data-name={@gist.name}>
            <pre><code class="language-elixir">
              <%= @gist.markup_text %>
            </code></pre>
          </div>
        </div>
    </div>
    """
  end
end
