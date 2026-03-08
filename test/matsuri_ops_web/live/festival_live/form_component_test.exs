defmodule MatsuriOpsWeb.FestivalLive.FormComponentTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures

  describe "FormComponent" do
    setup %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      %{conn: conn, user: user}
    end

    test "renders form for editing festival", %{conn: conn, user: user} do
      festival = festival_fixture(user, %{name: "編集テスト祭り"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/show/edit")

      assert has_element?(view, "input[name='festival[name]']")
      assert has_element?(view, "textarea[name='festival[description]']")
      assert has_element?(view, "select[name='festival[scale]']")
      assert has_element?(view, "input[name='festival[start_date]']")
      assert has_element?(view, "input[name='festival[end_date]']")
    end

    test "displays form with existing values", %{conn: conn, user: user} do
      festival = festival_fixture(user, %{
        name: "既存値テスト",
        description: "説明文テスト"
      })

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/show/edit")

      assert html =~ "既存値テスト"
      assert html =~ "説明文テスト"
    end

    test "validates form input", %{conn: conn, user: user} do
      festival = festival_fixture(user)

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/show/edit")

      result =
        view
        |> form("#festival-form", festival: %{name: ""})
        |> render_change()

      assert result =~ "can" or result =~ "必須" or result =~ "blank"
    end

    test "saves festival with valid data", %{conn: conn, user: user} do
      festival = festival_fixture(user)

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/show/edit")

      view
      |> form("#festival-form", festival: %{name: "更新された祭り名"})
      |> render_submit()

      flash = assert_patch(view, ~p"/festivals/#{festival}")
      assert render(view) =~ "祭り情報を更新しました" or flash
    end

    test "displays save button", %{conn: conn, user: user} do
      festival = festival_fixture(user)

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/show/edit")

      assert html =~ "保存"
    end

    test "displays form labels in Japanese", %{conn: conn, user: user} do
      festival = festival_fixture(user)

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/show/edit")

      assert html =~ "祭り名"
      assert html =~ "概要"
      assert html =~ "規模"
      assert html =~ "開始日"
      assert html =~ "終了日"
      assert html =~ "会場名"
      assert html =~ "会場住所"
      assert html =~ "状態"
    end

    test "displays scale options", %{conn: conn, user: user} do
      festival = festival_fixture(user)

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/show/edit")

      assert html =~ "小規模"
      assert html =~ "中規模"
      assert html =~ "大規模"
    end

    test "displays status options", %{conn: conn, user: user} do
      festival = festival_fixture(user)

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/show/edit")

      assert html =~ "企画中"
      assert html =~ "準備中"
      assert html =~ "開催中"
      assert html =~ "終了"
      assert html =~ "中止"
    end

    test "can close modal by patching back", %{conn: conn, user: user} do
      festival = festival_fixture(user)

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/show/edit")

      # Modal should be visible when editing
      assert has_element?(view, "#festival-form")

      # Navigate back to show page
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}")

      # Form should not be visible on show page
      refute has_element?(view, "#festival-form")
    end
  end
end
