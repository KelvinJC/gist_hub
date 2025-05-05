defmodule GistHubWeb.UserResetPasswordLive do
  use GistHubWeb, :live_view

  alias GistHub.Accounts

  def render(assigns) do
    ~H"""
    <div class="gh-gradient flex justify-center items-center">
      <h1 class="font-brand font-bold text-3xl text-white">Reset Password</h1>
    </div>
    <div class="mx-auto max-w-sm space-y-12">
      <.form
        for={@form}
        id="reset_password_form"
        phx-submit="reset_password"
        phx-change="validate"
      >
        <.error :if={@form.errors != []}>
          Oops, something went wrong! Please check the errors below.
        </.error>
        <div class="justify-center space-y-8 w-full mb-10">
          <div id="new_pwd_wrapper" class="flex relative">
            <div class="w-full">
              <.input
                id="new_pwd"
                field={@form[:password]}
                type={@show_password && "text" || "password"}
                value={@pwd_field || ""}
                placeholder="New password"
                required
              />
            </div>
            <%= if @pwd_field_has_text do %>
              <button
                id="hide_new_pwd"
                class="absolute right-0 mt-3 py-2 px-2 toggle-pwd-btn"
                phx-click="toggle_pwd_visibility"
                phx-value-button="new_pwd"
              >
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="white" class="size-4 toggle-pwd-icon">
                  <%= if @show_password do %>
                  <path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 0 0 1.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.451 10.451 0 0 1 12 4.5c4.756 0 8.773 3.162 10.065 7.498a10.522 10.522 0 0 1-4.293 5.774M6.228 6.228 3 3m3.228 3.228 3.65 3.65m7.894 7.894L21 21m-3.228-3.228-3.65-3.65m0 0a3 3 0 1 0-4.243-4.243m4.242 4.242L9.88 9.88" />
                  <% else %>
                  <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
                  <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                  <% end %>
                </svg>
              </button>
            <% end %>
          </div>
          <div id="confirm_pwd_wrapper" class="flex relative">
            <div class="w-full">
              <.input
                id="confirm_pwd"
                field={@form[:password_confirmation]}
                type={@show_confirm_password && "text" || "password"}
                value={@confirm_pwd_field || ""}
                placeholder="Confirm new password"
                required
              />
            </div>
            <%= if @confirm_pwd_field_has_text do %>
              <button
                id="hide_confirm_pwd"
                class="absolute right-0 mt-3 py-2 px-2 toggle-pwd-btn"
                phx-click="toggle_pwd_visibility"
                phx-value-button="confirm_pwd"
              >
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" class="size-4 toggle-pwd-icon">
                  <%= if @show_confirm_password do %>
                    <path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 0 0 1.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.451 10.451 0 0 1 12 4.5c4.756 0 8.773 3.162 10.065 7.498a10.522 10.522 0 0 1-4.293 5.774M6.228 6.228 3 3m3.228 3.228 3.65 3.65m7.894 7.894L21 21m-3.228-3.228-3.65-3.65m0 0a3 3 0 1 0-4.243-4.243m4.242 4.242L9.88 9.88" />
                  <% else %>
                    <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
                    <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                  <% end %>
                </svg>
              </button>
            <% end %>
          </div>
        </div>
          <.button phx-disable-with="Resetting..." class="create_button w-full">Reset Password</.button>
      </.form>
      <p class="font-brand font-regular text-center text-sm text-ghDark-light mt-4">
        <.link
          class="hover:underline hover:text-ghLavender-dark mr-2"
          href={~p"/users/register"}
        >
          Register
        </.link>
        |
        <.link
          class="hover:underline hover:text-ghLavender-dark ml-2"
          href={~p"/users/log_in"}
        >
          Log in
        </.link>
      </p>
    </div>
    """
  end

  def mount(params, _session, socket) do
    socket =
      socket
      |> assign_user_and_token(params)
      |> assign(
        page_title: "Password reset",
        pwd_field: "",
        confirm_pwd_field: "",
        show_password: false,
        show_confirm_password: false,
        pwd_field_has_text: false,
        confirm_pwd_field_has_text: false
      )

    form_source =
      case socket.assigns do
        %{user: user} ->
          Accounts.change_user_password(user)

        _ ->
          %{}
      end

    {:ok, assign_form(socket, form_source), temporary_assigns: [form: nil]}
  end

  # Do not log in the user after reset password to avoid a
  # leaked token giving the user access to the account.
  def handle_event("reset_password", %{"user" => user_params}, socket) do
    case Accounts.reset_user_password(socket.assigns.user, user_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password reset successfully.")
         |> redirect(to: ~p"/users/log_in")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, Map.put(changeset, :action, :insert))}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    socket =
      assign(
        socket,
        pwd_field: user_params["password"],
        confirm_pwd_field: user_params["password_confirmation"],
        pwd_field_has_text: String.length(user_params["password"]) > 0,
        confirm_pwd_field_has_text: String.length(user_params["password_confirmation"]) > 0
      )
    changeset = Accounts.change_user_password(socket.assigns.user, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  def handle_event("toggle_pwd_visibility", %{"button" => button}, socket) do
    socket =
      case button do
        "new_pwd" ->
          assign(socket, :show_password, !socket.assigns.show_password)
        "confirm_pwd" ->
          assign(socket, :show_confirm_password, !socket.assigns.show_confirm_password)
        _ ->
          socket
      end
    {:noreply, socket}
  end

  defp assign_user_and_token(socket, %{"token" => token}) do
    if user = Accounts.get_user_by_reset_password_token(token) do
      assign(socket, user: user, token: token)
    else
      socket
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: ~p"/")
    end
  end

  defp assign_form(socket, %{} = source) do
    assign(socket, :form, to_form(source, as: "user"))
  end
end
