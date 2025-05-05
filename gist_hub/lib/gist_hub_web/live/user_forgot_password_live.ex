defmodule GistHubWeb.UserForgotPasswordLive do
  use GistHubWeb, :live_view

  alias GistHub.Accounts

  def render(assigns) do
    ~H"""
    <div class="gh-gradient flex flex-col items-center justify-center">
      <h1 class="font-brand font-bold text-3xl text-white py-4">
        Forgot your password?
      </h1>
      <h2 class="font-brand font-regular text-sm text-ghDark-light">
        We'll send a password reset link to your inbox
      </h2>
    </div>
    <div class="mx-auto max-w-sm space-y-12">
      <.form for={@form} id="reset_password_form" phx-submit="send_email">
        <div class="justify-center w-full mb-10">
          <.input
            field={@form[:email]}
            type="email"
            placeholder="Email"
            required
          />
        </div>
        <.button
          phx-disable-with="Sending..."
          class="create_button w-full"
          >
          Send password reset instructions
        </.button>
      </.form>
      <p class="font-brand font-regular text-center text-sm mt-4 text-ghDark-light">
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

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"), page_title: "Forgot Password")}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/users/log_in")}
  end
end
