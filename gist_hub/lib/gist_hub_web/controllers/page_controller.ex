defmodule GistHubWeb.PageController do
  use GistHubWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: "/create")
  end
end
