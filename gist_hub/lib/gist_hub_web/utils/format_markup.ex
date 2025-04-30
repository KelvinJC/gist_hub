defmodule GistHubWeb.Utils.FormatMarkup do
  def get_preview_text(markup_text) when not is_nil(markup_text) do
    lines =
      markup_text
      |> String.trim()
      |> String.split("\n")
      if length(lines) > 10 do
        Enum.take(lines, 10)
        |> Enum.join("\n")
      else
        markup_text
      end
  end

  def get_preview_text(_), do: ""
end
