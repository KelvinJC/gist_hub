defmodule GistHubWeb.UserRegistrationLive do
  use GistHubWeb, :live_view
  alias GistHub.{Accounts, Accounts.User}

  def render(assigns) do
    ~H"""
    <div class="gh-gradient flex flex-col items-center justify-center">
      <h1 class="font-brand font-bold text-white text-3xl py-4">
        Register for an account
      </h1>
      <h2 class="font-brand font-regular text-ghDark-light text-sm">
        Already registered?
        <.link
          navigate={~p"/users/log_in"}
          class="font-brand text-ghLavender-dark text-brand hover:underline hover:text-ghPurple"
        >
          Sign in
        </.link>
          to your account now.
      </h2>
    </div>
    <div class="mx-auto max-w-sm">
      <.form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
      >
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>
        <div class="justify-center w-full space-y-8 mb-10">
          <.input
          field={@form[:email]}
          type="email"
          placeholder="Email"
          required
          />
          <div class="flex relative">
            <div class="w-full">
              <.input
                id="pwd_field"
                field={@form[:password]}
                value={@pwd_field || ""}
                type={@show_password && "text" || "password"}
                placeholder="Password"
                required
              />
            </div>
            <%= if @pwd_field_has_text do %>
              <div
                id="toggle_pwd"
                class="absolute right-3 mt-5 cursor-pointer"
                phx-click="toggle"
                phx-value-field="pwd_field"
              >
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="white" class="size-4 toggle-pwd-icon">
                  <%= if @show_password do %>
                    <path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 0 0 1.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.451 10.451 0 0 1 12 4.5c4.756 0 8.773 3.162 10.065 7.498a10.522 10.522 0 0 1-4.293 5.774M6.228 6.228 3 3m3.228 3.228 3.65 3.65m7.894 7.894L21 21m-3.228-3.228-3.65-3.65m0 0a3 3 0 1 0-4.243-4.243m4.242 4.242L9.88 9.88" />
                  <% else %>
                    <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
                    <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                  <% end %>
                </svg>
              </div>
            <% end %>
          </div>
          <div class="flex relative">
            <div class="w-full">
              <.input
                id="pwd_confirm_field"
                field={@form[:password_confirmation]}
                value={@pwd_confirm_field || ""}
                type={@show_pwd_confirm_field && "text" || "password"}
                placeholder="Confirm password"
                required
              />
            </div>
            <%= if @pwd_confirm_field_has_text do %>
              <div
                id="toggle_confirm_pwd"
                class="absolute right-3 mt-5 cursor-pointer"
                phx-click="toggle"
                phx-value-field="pwd_confirm_field"
              >
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="white" class="size-4 toggle-pwd-icon">
                  <%= if @show_pwd_confirm_field do %>
                    <path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 0 0 1.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.451 10.451 0 0 1 12 4.5c4.756 0 8.773 3.162 10.065 7.498a10.522 10.522 0 0 1-4.293 5.774M6.228 6.228 3 3m3.228 3.228 3.65 3.65m7.894 7.894L21 21m-3.228-3.228-3.65-3.65m0 0a3 3 0 1 0-4.243-4.243m4.242 4.242L9.88 9.88" />
                  <% else %>
                    <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
                    <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                  <% end %>
                </svg>
              </div>
            <% end %>
          </div>
          <div class="flex justify-end">
            <.button
              class="create_button w-full"
              phx-disable-with="Creating account..."
            >
              Create an account
            </.button>
          </div>
        </div>
      </.form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(
        page_title: "Sign up",
        trigger_submit: false,
        check_errors: false,
        show_password: false,
        pwd_field_has_text: false,
        pwd_field: "",
        show_pwd_confirm_field: false,
        pwd_confirm_field_has_text: false,
        pwd_confirm_field: ""
      )
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    socket = assign(
      socket,
      pwd_field: user_params["password"],
      pwd_field_has_text: String.length(user_params["password"] ) > 0,
      pwd_confirm_field: user_params["password_confirmation"],
      pwd_confirm_field_has_text: String.length(user_params["password_confirmation"] ) > 0
    )
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  def handle_event("toggle", %{"field" => field}, socket) do
    socket =
      case field do
        "pwd_field" ->
          assign(socket, :show_password, !socket.assigns.show_password)
        "pwd_confirm_field" ->
          assign(socket, :show_pwd_confirm_field, !socket.assigns.show_pwd_confirm_field)
        _ ->
          socket
      end
    {:noreply, socket}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
