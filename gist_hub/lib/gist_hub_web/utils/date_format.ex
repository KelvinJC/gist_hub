defmodule GistHubWeb.Utils.DateFormat do
  use Timex

  def get_relative_time(datetime) do
    {:ok, relative_time} = Timex.format(datetime, "{relative}", :relative)
    relative_time
  end
end
