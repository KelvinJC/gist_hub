defmodule GistHub.Repo.Migrations.GistsAddViewCountColumn do
  use Ecto.Migration

  def change do
    alter table("gists") do
      add :views, :integer, default: 0
    end
  end
end
