defmodule GistHubWeb.Utils.FormatUsername do
  def strip_name_from_email(email) do
    email
    |> String.split("@")
    |> hd()
  end
end
