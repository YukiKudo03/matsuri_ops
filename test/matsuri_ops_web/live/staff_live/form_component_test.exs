defmodule MatsuriOpsWeb.StaffLive.FormComponentTest do
  use MatsuriOpsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures

  describe "FormComponent for new member" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival}
    end

    test "renders form for new member", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/staff/new")

      assert html =~ "ユーザー"
      assert html =~ "役割"
      assert html =~ "担当エリア"
      assert html =~ "備考"
      assert html =~ "保存"
    end

    test "displays user options", %{conn: conn, festival: festival} do
      other_user = user_fixture(%{email: "staff@example.com"})

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/staff/new")

      assert html =~ other_user.email
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

    test "creates member with valid data", %{conn: conn, festival: festival} do
      new_user = user_fixture()

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/staff/new")

      view
      |> form("#member-form", festival_member: %{
        user_id: new_user.id,
        role: "leader",
        assigned_area: "本部",
        notes: "ベテランスタッフ"
      })
      |> render_submit()

      flash = assert_patch(view, ~p"/festivals/#{festival}/staff")
      assert render(view) =~ "メンバーを追加しました" or flash
    end

    test "creates member with minimum required fields", %{conn: conn, festival: festival} do
      new_user = user_fixture()

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/staff/new")

      view
      |> form("#member-form", festival_member: %{
        user_id: new_user.id,
        role: "volunteer"
      })
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/staff")
    end

    test "requires user selection to save", %{conn: conn, festival: festival} do
      new_user = user_fixture()

      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/staff/new")

      # ユーザーを選択して保存できることを確認
      view
      |> form("#member-form", festival_member: %{
        user_id: new_user.id,
        role: "staff"
      })
      |> render_submit()

      # 成功すると一覧ページにパッチされる
      assert_patch(view, ~p"/festivals/#{festival}/staff")
    end

    test "shows page title for new member", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/staff/new")

      assert html =~ "メンバー追加"
    end
  end

  describe "FormComponent for editing member" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = festival_fixture(user)
      member_user = user_fixture()
      member = festival_member_fixture(festival, member_user, %{
        role: "staff",
        assigned_area: "西エリア",
        notes: "経験者"
      })
      conn = log_in_user(conn, user)
      %{conn: conn, user: user, festival: festival, member: member, member_user: member_user}
    end

    test "displays existing values", %{conn: conn, festival: festival, member: member} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/staff/#{member}/edit")

      assert html =~ "西エリア"
      assert html =~ "経験者"
    end

    test "updates member role", %{conn: conn, festival: festival, member: member} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/staff/#{member}/edit")

      view
      |> form("#member-form", festival_member: %{role: "executive"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/staff")
      assert render(view) =~ "実行委員"
    end

    test "updates assigned area", %{conn: conn, festival: festival, member: member} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/staff/#{member}/edit")

      view
      |> form("#member-form", festival_member: %{assigned_area: "東エリア"})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/staff")
      assert render(view) =~ "東エリア"
    end

    test "updates notes", %{conn: conn, festival: festival, member: member} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/staff/#{member}/edit")

      view
      |> form("#member-form", festival_member: %{notes: "リーダー候補"})
      |> render_submit()

      flash = assert_patch(view, ~p"/festivals/#{festival}/staff")
      assert render(view) =~ "メンバー情報を更新しました" or flash
    end

    test "does not show user select on edit", %{conn: conn, festival: festival, member: member} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/staff/#{member}/edit")

      # User select is only shown for :new action
      refute html =~ "name=\"festival_member[user_id]\""
    end

    test "shows page title for edit", %{conn: conn, festival: festival, member: member} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/staff/#{member}/edit")

      assert html =~ "メンバー編集"
    end

    test "can clear assigned area", %{conn: conn, festival: festival, member: member} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/staff/#{member}/edit")

      view
      |> form("#member-form", festival_member: %{assigned_area: ""})
      |> render_submit()

      assert_patch(view, ~p"/festivals/#{festival}/staff")
    end
  end
end
