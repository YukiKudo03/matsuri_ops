defmodule MatsuriOpsWeb.LocaleConfig do
  @moduledoc """
  ロケール設定を一元管理するモジュール。

  アプリケーション全体で使用されるロケール定数と
  バリデーション関数を提供する。
  """

  @locales ~w(ja vi)
  @default_locale "ja"

  @doc """
  サポートされるロケールのリストを返す。
  """
  def locales, do: @locales

  @doc """
  デフォルトロケールを返す。
  """
  def default_locale, do: @default_locale

  @doc """
  ロケールを検証し、有効なロケールを返す。
  無効な場合はデフォルトロケールを返す。
  """
  def validate_locale(locale) when locale in @locales, do: locale
  def validate_locale(_), do: @default_locale

  @doc """
  ロケールが有効かどうかを確認する。
  """
  def valid_locale?(locale), do: locale in @locales

  @doc """
  ロケール切替時のメッセージを返す。
  """
  def locale_switched_message("ja"), do: "言語を日本語に切り替えました"
  def locale_switched_message("vi"), do: "Đã chuyển sang tiếng Việt"
  def locale_switched_message(_), do: "Language changed"

  @doc """
  ロケールの表示名を返す。
  """
  def locale_display_name("ja"), do: "日本語"
  def locale_display_name("vi"), do: "Tiếng Việt"
  def locale_display_name(locale), do: locale
end
