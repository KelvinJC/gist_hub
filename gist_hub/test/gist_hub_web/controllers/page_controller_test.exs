defmodule GistHubWeb.PageControllerTest do
  use GistHubWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    # assert html_response(conn, 200) =~ "Peace of mind from prototype to production"
    assert html_response(conn, 302) =~ "<html><body>You are being <a href=\"/create\">redirected</a>.</body></html>"
  end
end
