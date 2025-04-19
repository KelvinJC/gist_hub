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
            <div class="text-base font-brand text-sm">
              <span class="text-white"><%= @gist.user_id %></span> <span class="font-bold text-white">/</span>
              <.link
              href= {~p"/gist/?id=#{@gist.id}"}
              class="text-ghLavender-dark hover:underline"
              >
              <%= @gist.name %>
              </.link>
            </div>
            <div class="font-brand text-ghDark-light text-xs">
              <%= "Updated " <> DateFormat.get_relative_time(@gist.updated_at) %>
            </div>
            <p class="text-ghDark-light text-xs">
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
        <div id="gist-wrapper" class="flex w-full" >
          <textarea id="syntax-line-numbers" class="all-syntax-numbers rounded-bl-md" readonly></textarea>
          <div id="highlight" class="all-syntax-area w-full rounded-br-md" phx-hook="Highlight" data-name={@gist.name} all-gists-flag="true">
            <pre><code class="language-elixir"><%= get_preview_text(@gist.markup_text) %></code></pre>
          </div>
        </div>
    </div>
    """
  end

  defp get_preview_text(markup_text) when not is_nil(markup_text) do
    lines =
      markup_text
      |> String.trim()
      |> String.split("\n")
      if length(lines) > 10 do
        Enum.take(lines, 10)
        |> Enum.join("\n")
      else
        markup_text
      end
  end

  defp get_preview_text(_), do: ""
end
