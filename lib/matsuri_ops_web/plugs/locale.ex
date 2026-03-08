defmodule MatsuriOpsWeb.Plugs.Locale do
  @moduledoc """
  ロケール設定を行うPlug。

  セッションからロケールを取得し、Gettextに設定する。
  """

  import Plug.Conn
  @behaviour Plug

  @locales ~w(ja vi)
  @default_locale "ja"

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    locale = get_locale(conn)
    Gettext.put_locale(MatsuriOpsWeb.Gettext, locale)
    assign(conn, :locale, locale)
  end

  defp get_locale(conn) do
    cond do
      locale = conn.params["locale"] ->
        validate_locale(locale)

      locale = get_session(conn, :locale) ->
        validate_locale(locale)

      true ->
        @default_locale
    end
  end

  defp validate_locale(locale) when locale in @locales, do: locale
  defp validate_locale(_), do: @default_locale
end
