defmodule MatsuriOpsWeb.LocaleConfigTest do
  @moduledoc """
  ロケール設定モジュールのテスト。
  """

  use ExUnit.Case, async: true

  alias MatsuriOpsWeb.LocaleConfig

  describe "locales/0" do
    test "returns supported locales" do
      assert LocaleConfig.locales() == ~w(ja vi)
    end
  end

  describe "default_locale/0" do
    test "returns default locale" do
      assert LocaleConfig.default_locale() == "ja"
    end
  end

  describe "validate_locale/1" do
    test "returns valid locale as-is" do
      assert LocaleConfig.validate_locale("ja") == "ja"
      assert LocaleConfig.validate_locale("vi") == "vi"
    end

    test "returns default for invalid locale" do
      assert LocaleConfig.validate_locale("en") == "ja"
      assert LocaleConfig.validate_locale("invalid") == "ja"
      assert LocaleConfig.validate_locale(nil) == "ja"
    end
  end

  describe "valid_locale?/1" do
    test "returns true for valid locales" do
      assert LocaleConfig.valid_locale?("ja") == true
      assert LocaleConfig.valid_locale?("vi") == true
    end

    test "returns false for invalid locales" do
      assert LocaleConfig.valid_locale?("en") == false
      assert LocaleConfig.valid_locale?("invalid") == false
    end
  end

  describe "locale_switched_message/1" do
    test "returns appropriate message for each locale" do
      assert LocaleConfig.locale_switched_message("ja") == "言語を日本語に切り替えました"
      assert LocaleConfig.locale_switched_message("vi") == "Đã chuyển sang tiếng Việt"
    end

    test "returns English fallback for unknown locale" do
      assert LocaleConfig.locale_switched_message("en") == "Language changed"
    end
  end

  describe "locale_display_name/1" do
    test "returns display names for known locales" do
      assert LocaleConfig.locale_display_name("ja") == "日本語"
      assert LocaleConfig.locale_display_name("vi") == "Tiếng Việt"
    end

    test "returns locale code for unknown locale" do
      assert LocaleConfig.locale_display_name("en") == "en"
    end
  end
end
