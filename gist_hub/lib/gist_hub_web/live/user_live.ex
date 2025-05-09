defmodule GistHubWeb.UserProfileLive do
  use GistHubWeb, :live_view
  import GistHubWeb.GistComponent
  alias GistHubWeb.InvalidUsername
  alias GistHub.Gists
  alias GistHubWeb.Utils.FormatUsername
  alias GistHubWeb.{InvalidUsername, UserProfileNotFound}

  def mount(_params, _session, socket) do
    socket = assign(
      socket,
      gists: [],
      page_title: "Users"
    )
    {:ok, socket}
  end

  def handle_params(%{"username" => username}, _uri, socket)
    when username == "" or not is_binary(username) or is_nil(username)
  do
    raise InvalidUsername, "invalid username #{inspect(username)}"
  end

  def handle_params(%{"username"=> username}, _uri, socket) do
    case Gists.list_gists_by_user(username) do
      {:ok, user} ->
        {:noreply,
          assign(
            socket,
            gists: user.gists,
            username: FormatUsername.strip_name_from_email(user.email),
            email: user.email,
            sort_by_updated_at: true
        )}

      {:error, _} ->
        raise UserProfileNotFound, "unknown username #{inspect(username)}"
    end
  end

  def render(assigns) do
    ~H"""
    <div class="gh-gradient flex items-center">
      <div class="ml-10">
        <img
          src="/images/profile_gist2.jpg"
          alt="Profile Image"
          class="rounded-full w-40 h-40"
        >
      </div>
    </div>
    <div class="ml-8 flex w-full">
      <div>
        <div class="max-w-sm space-y-8">
          <div class="flex-col justify-center items-center font-brand">
            <p class="text-white text-3xl font-regular">Chika Ijeoma</p>
            <p class="text-ghDark-light text-xl">{@username}</p>
          </div>
          <div class="font-brand font-regular text-sm space-y-4 text-ghDark-light">
            <span class="flex items-center space-x-2">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5">
                <path stroke-linecap="round" stroke-linejoin="round" d="M21.75 9v.906a2.25 2.25 0 0 1-1.183 1.981l-6.478 3.488M2.25 9v.906a2.25 2.25 0 0 0 1.183 1.981l6.478 3.488m8.839 2.51-4.66-2.51m0 0-1.023-.55a2.25 2.25 0 0 0-2.134 0l-1.022.55m0 0-4.661 2.51m16.5 1.615a2.25 2.25 0 0 1-2.25 2.25h-15a2.25 2.25 0 0 1-2.25-2.25V8.844a2.25 2.25 0 0 1 1.183-1.981l7.5-4.039a2.25 2.25 0 0 1 2.134 0l7.5 4.039a2.25 2.25 0 0 1 1.183 1.98V19.5Z" />
              </svg>
              <p>{@email}</p>
            </span>
            <span class="flex items-center space-x-2">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5">
                <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 21h19.5m-18-18v18m10.5-18v18m6-13.5V21M6.75 6.75h.75m-.75 3h.75m-.75 3h.75m3-6h.75m-.75 3h.75m-.75 3h.75M6.75 21v-3.375c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21M3 3h12m-.75 4.5H21m-3.75 3.75h.008v.008h-.008v-.008Zm0 3h.008v.008h-.008v-.008Zm0 3h.008v.008h-.008v-.008Z" />
              </svg>
              <p>Socket.IO</p>
            </span>
            <span class="flex items-center space-x-2">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5">
                <path stroke-linecap="round" stroke-linejoin="round" d="M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1 1 15 0Z" />
              </svg>
              <p>Stockholm, Sweden</p>
            </span>
            <span class="flex items-center space-x-2">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5">
                <path stroke-linecap="round" stroke-linejoin="round" d="M6 12 3.269 3.125A59.769 59.769 0 0 1 21.485 12 59.768 59.768 0 0 1 3.27 20.875L5.999 12Zm0 0h7.5" />
              </svg>
              <p>https://github.com/{@username}</p>
            </span>
            <span class="flex items-center space-x-2">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5">
                <path stroke-linecap="round" stroke-linejoin="round" d="M13.19 8.688a4.5 4.5 0 0 1 1.242 7.244l-4.5 4.5a4.5 4.5 0 0 1-6.364-6.364l1.757-1.757m13.35-.622 1.757-1.757a4.5 4.5 0 0 0-6.364-6.364l-4.5 4.5a4.5 4.5 0 0 0 1.242 7.244" />
              </svg>
              <p>www.gisthub.com</p>
            </span>
          </div>
        </div>
      </div>
      <div class="flex-1 min-w-0">
        <%= for {gist, index} <- Enum.with_index(@gists) do %>
          <.gist
              gist_path={~p"/#{@username}/#{gist.id}"}
              user_path={~p"/#{@username}"}
              username={@username}
              gist={gist}
              index={index}
              current_user={@current_user}
              sort_by_updated_at={@sort_by_updated_at}
          />
        <% end %>
      </div>
    </div>
    """
  end
end

defmodule GistHubWeb.InvalidUsername do
  @moduledoc false
  defexception [:message, plug_status: 404]
end

defmodule GistHubWeb.UserProfileNotFound do
  @moduledoc false
  defexception [:message, plug_status: 404]
end
