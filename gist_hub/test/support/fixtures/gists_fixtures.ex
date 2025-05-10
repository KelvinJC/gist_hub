defmodule GistHub.GistsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `GistHub.Gists` context.
  """

  @doc """
  Generate a gist.
  """

  import GistHub.AccountsFixtures
  alias GistHub.Repo

  def gist_fixture(gist_author \\ %{}, attrs \\ %{}) do
    user = gist_author == %{} && user_fixture() || gist_author
    attrs = Enum.into(attrs, %{
      description: "some description",
      markup_text: "some markup_text",
      name: "some name",
      user_id: user.id
      })
    {:ok, gist} = GistHub.Gists.create_gist(user, attrs)
    Repo.preload(gist, :user)
  end

  @doc """
  Generate a saved_gist.
  """
  def saved_gist_fixture(attrs \\ %{}) do
    {:ok, saved_gist} =
      attrs
      |> Enum.into(%{

      })
      |> GistHub.Gists.create_saved_gist()

    saved_gist
  end
end
