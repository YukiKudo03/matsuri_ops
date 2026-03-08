defmodule MatsuriOpsWeb.TemplateLive.IndexTest do
  @moduledoc """
  テンプレート管理LiveViewのテスト。

  TDDフェーズ: 🔴 RED
  - T-TPL-004: テンプレート管理LiveViewテスト
  """

  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures

  alias MatsuriOps.Templates

  describe "Index (認証が必要)" do
    setup :register_and_log_in_user

    test "テンプレート一覧ページが表示される", %{conn: conn, user: user} do
      {:ok, _template} = Templates.create_template(user, %{name: "テストテンプレート"})

      {:ok, _lv, html} = live(conn, ~p"/templates")

      assert html =~ "テンプレート一覧"
      assert html =~ "テストテンプレート"
    end

    test "新規テンプレート作成ボタンが表示される", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/templates")

      assert html =~ "新規作成"
    end

    test "新規テンプレート作成モーダルが表示される", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/templates")

      result =
        lv
        |> element("a", "新規作成")
        |> render_click()

      assert result =~ "新規テンプレート"
    end

    test "テンプレートを作成できる", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/templates/new")

      form_data = %{
        "template" => %{
          "name" => "新しいテンプレート",
          "description" => "説明文",
          "scale" => "medium"
        }
      }

      lv
      |> form("#template-form", form_data)
      |> render_submit()

      # push_patchでモーダルが閉じてテンプレート一覧が更新される
      html = render(lv)
      assert html =~ "新しいテンプレート"
    end

    test "テンプレートを編集できる", %{conn: conn, user: user} do
      {:ok, template} = Templates.create_template(user, %{name: "編集前"})

      {:ok, lv, _html} = live(conn, ~p"/templates/#{template}/edit")

      form_data = %{
        "template" => %{
          "name" => "編集後"
        }
      }

      lv
      |> form("#template-form", form_data)
      |> render_submit()

      # push_patchでモーダルが閉じてテンプレート一覧が更新される
      html = render(lv)
      assert html =~ "編集後"
    end

    test "テンプレートを削除できる", %{conn: conn, user: user} do
      {:ok, template} = Templates.create_template(user, %{name: "削除対象"})

      {:ok, lv, _html} = live(conn, ~p"/templates")

      assert render(lv) =~ "削除対象"

      # data-confirm付きのリンクをクリック
      lv
      |> element("#templates-#{template.id} a", "削除")
      |> render_click()

      refute render(lv) =~ "削除対象"
    end

    test "テンプレートをコピーできる", %{conn: conn, user: user} do
      {:ok, template} = Templates.create_template(user, %{name: "オリジナル"})

      {:ok, lv, _html} = live(conn, ~p"/templates")

      lv
      |> element("#templates-#{template.id} a", "コピー")
      |> render_click()

      html = render(lv)
      assert html =~ "オリジナル"
      assert html =~ "オリジナル (コピー)"
    end

    test "公開テンプレートは他のユーザーにも表示される", %{conn: conn} do
      other_user = user_fixture()
      {:ok, _template} = Templates.create_template(other_user, %{name: "公開テンプレート", is_public: true})

      {:ok, _lv, html} = live(conn, ~p"/templates")

      assert html =~ "公開テンプレート"
    end

    test "非公開テンプレートは他のユーザーには表示されない", %{conn: conn} do
      other_user = user_fixture()
      {:ok, _template} = Templates.create_template(other_user, %{name: "非公開テンプレート", is_public: false})

      {:ok, _lv, html} = live(conn, ~p"/templates")

      refute html =~ "非公開テンプレート"
    end
  end

  describe "テンプレート適用" do
    setup :register_and_log_in_user

    test "テンプレートから祭りを作成できる", %{conn: conn, user: user} do
      {:ok, template} = Templates.create_template(user, %{
        name: "祭りテンプレート",
        scale: "large",
        default_expected_visitors: 10000
      })

      {:ok, lv, _html} = live(conn, ~p"/templates/#{template}/apply")

      form_data = %{
        "festival" => %{
          "name" => "2026年玄蕃まつり",
          "start_date" => "2026-08-01",
          "end_date" => "2026-08-02"
        }
      }

      {:ok, _lv, html} =
        lv
        |> form("#apply-template-form", form_data)
        |> render_submit()
        |> follow_redirect(conn, ~p"/festivals")

      # push_navigateでFestivalLive.Indexにリダイレクト
      assert html =~ "2026年玄蕃まつり"
    end
  end

  describe "未認証ユーザー" do
    test "テンプレート一覧にアクセスできない", %{conn: conn} do
      {:error, redirect} = live(conn, ~p"/templates")

      assert {:redirect, %{to: path}} = redirect
      assert path =~ "/users/log-in"
    end
  end
end
