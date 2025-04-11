defmodule GistHubWeb.Layouts.App do
  alias Phoenix.Liveview.JS

  def toggle_dropdown_menu do
    JS.toggle(to: "#dropdown_menu")
  end
end
