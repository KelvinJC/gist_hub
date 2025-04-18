defmodule GistHubWeb.GistFormComponent do
  use GistHubWeb, :live_component
  alias GistHub.{Gists, Gists.Gist}

  def mount(socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <%= if @form do %>
        <.form for={@form} phx-submit="create" phx-change="validate" phx-target={@myself}>
          <div class="justify-center px-28 w-full space-y-4 mb-10">
            <.input
              field={@form[:description]}
              placeholder="Gist Description..."
              autocomplete="off"
              phx-debounce="blur"
            />
            <div>
              <div class="flex p-2 items-center bg-ghDark rounded-t-md border">
                <div class="w-[300px] mb-2">
                  <.input
                    field={@form[:name]}
                    placeholder="Filename including extension..."
                    autocomplete="off"
                    phx-debounce="blur"
                />
                </div>
              </div>
              <div id="gist-wrapper" class="flex w-full" phx-update="ignore">
                <textarea class="line-numbers rounded-bl-md" id="line-numbers" readonly><%= "1\n" %></textarea>
                <div class="flex-grow">
                  <.input
                  type="textarea"
                  field={@form[:markup_text]}
                  id="gist-textarea"
                  phx-hook="UpdateLineNumbers"
                  class="textarea w-full rounded-br-md"
                  placeholder="Insert code..."
                  spellcheck="false"
                  autocomplete="off"
                  phx-debounce="blur"
                  />
                </div>
              </div>
            </div>
            <%= if @id == :new do %>
              <div class="flex justify-end">
                  <.button class="create_button" phx-disable-with="Creating...">Create gist</.button>
              </div>
            <% else %>
              <div class="flex justify-end">
                  <.button class="create_button" phx-disable-with="Updating...">Update gist</.button>
              </div>
            <% end %>
          </div>
        </.form>
      <% end %>
    </div>
    """
  end

  def handle_event("validate", %{"gist" => params}, socket) do
    changeset =
      %Gist{}
      |> Gists.change_gist(params)
      |> Map.put(:action, :validate)
    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("create", %{"gist" => params}, socket) do
    if socket.assigns.id == :new do
      create_gist(params, socket)
    else
      update_gist(params, socket)
    end
  end

  defp create_gist(params, socket) do
    case Gists.create_gist(socket.assigns.current_user, params) do
      {:ok, gist} ->
        # trigger client side event on successful creation of gist
        socket = push_event(socket, "clear-textarea", %{})
        changeset = Gists.change_gist(%Gist{})
        socket = assign(socket, :form, to_form(changeset))
        {:noreply, push_navigate(socket, to: ~p"/gist?#{[id: gist]}")}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp update_gist(params, socket) do
    params = Map.put(params, "id", socket.assigns.id)
    case Gists.update_gist(socket.assigns.current_user, params) do
      {:ok, gist} ->
        {:noreply, push_navigate(socket, to: ~p"/gist?#{[id: gist]}")}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
      {:error, :unauthorised} ->
        socket = put_flash(socket, :error, "Unauthorised.")
        {:noreply, socket}
      _ ->
        {:noreply, socket}
    end
  end
end
