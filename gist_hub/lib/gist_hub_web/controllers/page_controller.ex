defmodule GistHubWeb.PageController do
  use GistHubWeb, :controller

  def home(conn, _params) do
    render(conn, :home )
  end
end
