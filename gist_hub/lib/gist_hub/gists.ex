defmodule GistHub.Gists do
  @moduledoc """
  The Gists context.
  """

  import Ecto.Query, warn: false
  alias GistHub.Repo
  alias GistHub.Gists.Gist
  alias GistHub.Accounts.User

  @doc """
  Returns the sorted list of gists
  with most recently updated gist being first

  ## Examples

      iex> list_gists()
      [%Gist{}, ...]

  """
  def list_gists do
    Gist
    |> order_by(desc: :updated_at)
    |> Repo.all()
    |> Repo.preload(:user)
  end


  # NOTE:
  # like/2 i.e. like(string, search)
  # ---------------------------------
  # Translates to the underlying SQL LIKE query,
  # therefore its behaviour is dependent on the database.
  # In particular, PostgreSQL will do a case-sensitive operation,
  # while the majority of other databases will be case-insensitive.
  # For performing a case-insensitive like in PostgreSQL, see ilike/2.
  # You should be very careful when allowing user sent data to be used as part of LIKE query,
  # since they allow to perform LIKE-injections.
  def search(search_query) do
    search_query = "%#{search_query}%"
    Gist
    |> order_by(desc: :updated_at)
    |> where([g] , ilike(g.name, ^search_query))
    |> Repo.all()
    |> Repo.preload(:user)
  end

  def list_gists("least_recently_updated_at") do
    Gist
    |> order_by(asc: :updated_at)
    |> Repo.all()
    |> Repo.preload(:user)
  end

  def list_gists("recently_created_at") do
    Gist
    |> order_by(desc: :inserted_at)
    |> Repo.all()
    |> Repo.preload(:user)
  end

  def list_gists("least_recently_created_at") do
    Gist
    |> order_by(asc: :inserted_at)
    |> Repo.all()
    |> Repo.preload(:user)
  end

  @doc """
  Gets a single gist.

  Raises `Ecto.NoResultsError` if the Gist does not exist.

  ## Examples

      iex> get_gist!(123)
      %Gist{}

      iex> get_gist!(456)
      ** (Ecto.NoResultsError)

  """
  def get_gist!(id) do
    Repo.get!(Gist, id)
    |> Repo.preload(:user)
  end

  @doc """
  Creates a gist.

  ## Examples

      iex> create_gist(%{field: value})
      {:ok, %Gist{}}

      iex> create_gist(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_gist(%User{} = user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:gists)
    |> Gist.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Increments the view column of a gist without changing the updated_at field.
  See https://stackoverflow.com/a/40080478
  """
  def increment_gist_views(id) do
    Gist
    |> where(id: ^id)
    |> Repo.update_all(inc: [views: 1])
  end

  @doc """
  Updates a gist.

  ## Examples

      iex> update_gist(gist, %{field: new_value})
      {:ok, %Gist{}}

      iex> update_gist(gist, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_gist(%User{} = user, attrs) do
    gist = Repo.get!(Gist, attrs["id"])

    if gist.user_id == user.id do
      gist
      |> Gist.changeset(attrs)
      |> Repo.update()
    else
      {:error, :unauthorised}
    end
  end

  @doc """
  Deletes a gist.

  ## Examples

      iex> delete_gist(gist)
      {:ok, %Gist{}}

      iex> delete_gist(gist)
      {:error, %Ecto.Changeset{}}

  """
  def delete_gist(%User{} = user, gist_id) do
    gist = Repo.get!(Gist, gist_id)

    if user.id == gist.user_id do
      Repo.delete(gist)
      {:ok, gist}
    else
      {:error, :unauthorised}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking gist changes.

  ## Examples

      iex> change_gist(gist)
      %Ecto.Changeset{data: %Gist{}}

  """
  def change_gist(%Gist{} = gist, attrs \\ %{}) do
    Gist.changeset(gist, attrs)
  end

  alias GistHub.Gists.SavedGist

  @doc """
  Returns the list of saved_gists.

  ## Examples

      iex> list_saved_gists()
      [%SavedGist{}, ...]

  """
  def list_saved_gists do
    Repo.all(SavedGist)
  end

  @doc """
  Gets a single saved_gist.

  Raises `Ecto.NoResultsError` if the Saved gist does not exist.

  ## Examples

      iex> get_saved_gist!(123)
      %SavedGist{}

      iex> get_saved_gist!(456)
      ** (Ecto.NoResultsError)

  """
  def get_saved_gist!(id), do: Repo.get!(SavedGist, id)

  @doc """
  Creates a saved_gist.

  ## Examples

      iex> create_saved_gist(%{field: value})
      {:ok, %SavedGist{}}

      iex> create_saved_gist(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_saved_gist(%User{} = user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:saved_gists)
    |> SavedGist.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a saved_gist.

  ## Examples

      iex> update_saved_gist(saved_gist, %{field: new_value})
      {:ok, %SavedGist{}}

      iex> update_saved_gist(saved_gist, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_saved_gist(%SavedGist{} = saved_gist, attrs) do
    saved_gist
    |> SavedGist.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a saved_gist.

  ## Examples

      iex> delete_saved_gist(saved_gist)
      {:ok, %SavedGist{}}

      iex> delete_saved_gist(saved_gist)
      {:error, %Ecto.Changeset{}}

  """
  def delete_saved_gist(%SavedGist{} = saved_gist) do
    Repo.delete(saved_gist)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking saved_gist changes.

  ## Examples

      iex> change_saved_gist(saved_gist)
      %Ecto.Changeset{data: %SavedGist{}}

  """
  def change_saved_gist(%SavedGist{} = saved_gist, attrs \\ %{}) do
    SavedGist.changeset(saved_gist, attrs)
  end
end
