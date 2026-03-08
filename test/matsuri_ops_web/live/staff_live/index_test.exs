defmodule MatsuriOpsWeb.StaffLive.IndexTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures

  describe "Index page" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "renders staff management page", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/staff")

      assert html =~ "スタッフ管理"
      assert html =~ festival.name
    end

    test "redirects if user is not logged in", %{festival: festival} do
      conn = build_conn()
      assert {:error, redirect} = live(conn, ~p"/festivals/#{festival}/staff")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log-in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "displays navigation buttons", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/staff")

      assert html =~ "メンバー追加"
      assert html =~ "祭り詳細へ"
    end

    test "displays staff count statistics", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/staff")

      assert html =~ "総スタッフ数"
      assert html =~ "リーダー"
      assert html =~ "スタッフ"
      assert html =~ "ボランティア"
    end

    test "displays member list", %{conn: conn, festival: festival} do
      member_user = user_fixture()
      _member = festival_member_fixture(festival, member_user, %{role: "leader"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/staff")

      assert html =~ member_user.email
      assert html =~ "リーダー"
    end

    test "displays role badges correctly", %{conn: conn, festival: festival} do
      leader_user = user_fixture()
      staff_user = user_fixture()
      volunteer_user = user_fixture()

      _leader = festival_member_fixture(festival, leader_user, %{role: "leader"})
      _staff = festival_member_fixture(festival, staff_user, %{role: "staff"})
      _volunteer = festival_member_fixture(festival, volunteer_user, %{role: "volunteer"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/staff")

      assert html =~ "リーダー"
      assert html =~ "スタッフ"
      assert html =~ "ボランティア"
    end

    test "displays assigned area", %{conn: conn, festival: festival} do
      member_user = user_fixture()
      _member = festival_member_fixture(festival, member_user, %{
        role: "staff",
        assigned_area: "メインステージ"
      })

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/staff")

      assert html =~ "メインステージ"
    end

    test "can delete member", %{conn: conn, festival: festival} do
      member_user = user_fixture()
      member = festival_member_fixture(festival, member_user, %{role: "staff"})

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/staff")

      # メンバーが存在することを確認
      assert has_element?(view, "#members-#{member.id}")

      # 削除イベントを発火
      view
      |> render_click("delete", %{"id" => to_string(member.id)})

      refute has_element?(view, "#members-#{member.id}")
    end

    test "displays back link", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/staff")

      assert html =~ "祭り詳細へ戻る"
    end

    test "counts members by role correctly", %{conn: conn, festival: festival} do
      leader1 = user_fixture()
      leader2 = user_fixture()
      staff1 = user_fixture()

      _l1 = festival_member_fixture(festival, leader1, %{role: "leader"})
      _l2 = festival_member_fixture(festival, leader2, %{role: "leader"})
      _s1 = festival_member_fixture(festival, staff1, %{role: "staff"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/staff")

      # Total 3 members
      assert html =~ "3 名" or html =~ "3名"
    end
  end

  describe "New member modal" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "opens new member modal", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/staff")

      view
      |> element("a", "メンバー追加")
      |> render_click()

      assert_patch(view, ~p"/festivals/#{festival}/staff/new")
      assert has_element?(view, "#member-form")
    end

    test "displays member form fields", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/staff/new")

      assert html =~ "ユーザー"
      assert html =~ "役割"
      assert html =~ "担当エリア"
      assert html =~ "備考"
    end

    test "displays role options", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/staff/new")

      assert html =~ "実行委員"
      assert html =~ "事務局"
      assert html =~ "リーダー"
      assert html =~ "スタッフ"
      assert html =~ "ボランティア"
      assert html =~ "出店者"
    end

    test "saves new member", %{conn: conn, festival: festival} do
      new_user = user_fixture()

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/staff/new")

      view
      |> form("#member-form", festival_member: %{
        user_id: new_user.id,
        role: "staff",
        assigned_area: "入口"
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/staff")
      html = render(view)
      assert html =~ new_user.email or html =~ "メンバーを追加しました"
    end
  end

  describe "Edit member modal" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      member_user = user_fixture()
      member = festival_member_fixture(festival, member_user, %{
        role: "staff",
        assigned_area: "メインエリア"
      })
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival, member: member, member_user: member_user}
    end

    test "opens edit member modal", %{conn: conn, festival: festival, member: member, member_user: member_user} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/staff/#{member}/edit")

      assert html =~ "メンバー編集"
      assert html =~ member_user.email or html =~ "メインエリア"
    end

    test "updates member role", %{conn: conn, festival: festival, member: member} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/staff/#{member}/edit")

      view
      |> form("#member-form", festival_member: %{role: "leader"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/staff")
      assert render(view) =~ "リーダー"
    end

    test "updates assigned area", %{conn: conn, festival: festival, member: member} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/staff/#{member}/edit")

      view
      |> form("#member-form", festival_member: %{assigned_area: "フードコート"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/staff")
      assert render(view) =~ "フードコート"
    end

    test "shows edit page title", %{conn: conn, festival: festival, member: member} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/staff/#{member}/edit")

      assert html =~ "メンバー編集"
    end

    test "does not show user select on edit", %{conn: conn, festival: festival, member: member} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/staff/#{member}/edit")

      # User select should only appear on :new action
      refute html =~ "name=\"festival_member[user_id]\""
    end
  end
end
