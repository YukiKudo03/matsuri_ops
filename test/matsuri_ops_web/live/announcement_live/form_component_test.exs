defmodule MatsuriOpsWeb.AnnouncementLive.FormComponentTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.NotificationsFixtures

  describe "New announcement form" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "renders new announcement form", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/announcements/new")

      assert has_element?(view, "#announcement-form")
      assert has_element?(view, "input[name='announcement[title]']")
      assert has_element?(view, "textarea[name='announcement[content]']")
      assert has_element?(view, "select[name='announcement[priority]']")
      assert has_element?(view, "select[name='announcement[target_audience]']")
    end

    test "validates required fields", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/announcements/new")

      result =
        view
        |> form("#announcement-form", announcement: %{title: "", content: ""})
        |> render_change()

      assert result =~ "can" or result =~ "必須" or result =~ "blank"
    end

    test "saves new announcement", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/announcements/new")

      view
      |> form("#announcement-form", announcement: %{
        title: "新しいお知らせタイトル",
        content: "お知らせの内容です"
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/announcements")
      assert render(view) =~ "新しいお知らせタイトル"
    end

    test "displays expires_at field", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/announcements/new")

      assert html =~ "expires_at" or html =~ "有効期限"
    end
  end

  describe "Edit announcement form" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      announcement = announcement_fixture(festival, user, %{title: "編集対象お知らせ", content: "編集前の内容"})
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival, announcement: announcement}
    end

    test "renders edit form with existing values", %{conn: conn, festival: festival, announcement: announcement} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/announcements/#{announcement}/edit")

      assert html =~ "編集対象お知らせ"
      assert html =~ "編集前の内容"
    end

    test "updates existing announcement", %{conn: conn, festival: festival, announcement: announcement} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/announcements/#{announcement}/edit")

      view
      |> form("#announcement-form", announcement: %{title: "更新済みお知らせ"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/announcements")
      assert render(view) =~ "更新済みお知らせ"
    end
  end
end
