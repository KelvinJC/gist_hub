defmodule GistHub.Repo do
  use Ecto.Repo,
    otp_app: :gist_hub,
    adapter: Ecto.Adapters.Postgres
end
