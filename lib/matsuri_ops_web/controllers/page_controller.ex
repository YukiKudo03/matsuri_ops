defmodule MatsuriOpsWeb.PageController do
  use MatsuriOpsWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
