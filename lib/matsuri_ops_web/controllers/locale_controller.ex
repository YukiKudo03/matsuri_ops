defmodule MatsuriOpsWeb.LocaleController do
  @moduledoc """
  ロケール切り替えコントローラー。
  """

  use MatsuriOpsWeb, :controller

  @locales ~w(ja vi)

  def switch(conn, %{"locale" => locale}) do
    locale = if locale in @locales, do: locale, else: "ja"

    conn
    |> put_session(:locale, locale)
    |> put_flash(:info, locale_switched_message(locale))
    |> redirect(to: get_redirect_path(conn))
  end

  defp locale_switched_message("ja"), do: "言語を日本語に切り替えました"
  defp locale_switched_message("vi"), do: "Đã chuyển sang tiếng Việt"
  defp locale_switched_message(_), do: "Language switched"

  defp get_redirect_path(conn) do
    case get_req_header(conn, "referer") do
      [referer] ->
        uri = URI.parse(referer)
        uri.path || "/"

      _ ->
        "/"
    end
  end
end
