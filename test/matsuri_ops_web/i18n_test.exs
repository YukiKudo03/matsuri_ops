defmodule MatsuriOpsWeb.I18nTest do
  @moduledoc """
  国際化（i18n）機能のテスト。

  TDDフェーズ: 🔴 RED → 🟢 GREEN
  """

  use MatsuriOpsWeb.ConnCase
  use Gettext, backend: MatsuriOpsWeb.Gettext

  describe "ロケール設定" do
    test "デフォルトは日本語", %{conn: conn} do
      conn = get(conn, ~p"/")
      # ページが正常に表示される
      assert html_response(conn, 200)
      # ロケールがjaに設定されている
      assert conn.assigns.locale == "ja"
    end

    test "ベトナム語に切り替えできる", %{conn: conn} do
      # セッションを初期化してからロケールを設定
      conn =
        conn
        |> init_test_session(%{locale: "vi"})
        |> get(~p"/")

      assert html_response(conn, 200)
      assert conn.assigns.locale == "vi"
    end

    test "無効なロケールはデフォルトになる", %{conn: conn} do
      conn =
        conn
        |> init_test_session(%{locale: "invalid"})
        |> get(~p"/")

      assert conn.assigns.locale == "ja"
    end
  end

  describe "翻訳ヘルパー" do
    test "日本語翻訳が返される" do
      Gettext.put_locale(MatsuriOpsWeb.Gettext, "ja")
      assert gettext("Festival") == "祭り"
    end

    test "ベトナム語翻訳が返される" do
      Gettext.put_locale(MatsuriOpsWeb.Gettext, "vi")
      assert gettext("Festival") == "Lễ hội"
    end

    test "未翻訳のテキストはそのまま返される" do
      Gettext.put_locale(MatsuriOpsWeb.Gettext, "ja")
      assert gettext("Untranslated") == "Untranslated"
    end
  end

  describe "言語切替" do
    test "日本語に切り替えできる", %{conn: conn} do
      conn = get(conn, ~p"/locale/ja")

      assert redirected_to(conn) == "/"
      assert get_session(conn, :locale) == "ja"
    end

    test "ベトナム語に切り替えできる", %{conn: conn} do
      conn = get(conn, ~p"/locale/vi")

      assert redirected_to(conn) == "/"
      assert get_session(conn, :locale) == "vi"
    end

    test "無効なロケールはjaになる", %{conn: conn} do
      conn = get(conn, ~p"/locale/invalid")

      assert redirected_to(conn) == "/"
      assert get_session(conn, :locale) == "ja"
    end
  end
end
