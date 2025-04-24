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
          <.input 
          field={@form[:password]} 
          type="password" 
          placeholder="New password" 
          required 
          />
          <.input
            field={@form[:password_confirmation]}
            type="password"
            placeholder="Confirm new password"
            required
          />
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
    socket = assign_user_and_token(socket, params)

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
    changeset = Accounts.change_user_password(socket.assigns.user, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
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
