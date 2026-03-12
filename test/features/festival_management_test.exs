defmodule MatsuriOpsWeb.Features.FestivalManagementTest do
  @moduledoc """
  祭り管理機能のE2Eテスト (Suite 3: F-01〜F-09)
  """

  use MatsuriOpsWeb.FeatureCase, async: false

  describe "祭り一覧" do
    # F-01: 祭り一覧表示
    feature "ログインユーザーが祭り一覧を表示できる", %{session: session} do
      {session, _user} = register_and_login(session)

      session
      |> visit("/festivals")
      |> wait_for_liveview()
      |> assert_has(css("h1", text: "祭り一覧"))
    end
  end

  describe "祭りCRUD操作" do
    # F-02: 祭り新規作成
    feature "祭りを新規作成できる", %{session: session} do
      {session, _user} = register_and_login(session)
      festival_name = "夏祭りE2E#{System.unique_integer([:positive])}"

      session
      |> visit("/festivals")
      |> wait_for_liveview()
      |> click(link("新規作成"))
      |> wait_for_liveview(800)
      |> assert_has(css("#festival-form"))
      |> fill_in(css("#festival-form input[name='festival[name]']"), with: festival_name)
      # Chrome date inputはfill_inで値が設定されないためJSで設定
      |> set_date_input("#festival-form input[name='festival[start_date]']", "2026-08-01")
      |> set_date_input("#festival-form input[name='festival[end_date]']", "2026-08-03")
      |> fill_in(css("#festival-form input[name='festival[venue_name]']"), with: "中央公園")
      |> click(button("保存"))
      |> wait_for_liveview(1500)
      # 保存後一覧ページを再読み込みして確認
      |> visit("/festivals")
      |> wait_for_liveview()
      |> assert_has(css("td", text: festival_name))
    end

    # F-03: 必須項目バリデーション
    feature "名前未入力で保存するとエラー表示", %{session: session} do
      {session, _user} = register_and_login(session)

      session
      |> visit("/festivals")
      |> wait_for_liveview()
      |> click(link("新規作成"))
      |> wait_for_liveview(800)
      |> set_date_input("#festival-form input[name='festival[start_date]']", "2026-08-01")
      |> set_date_input("#festival-form input[name='festival[end_date]']", "2026-08-03")
      |> click(button("保存"))
      |> wait_for_liveview()
      # バリデーションエラーが表示される（モーダルが閉じない）
      |> assert_has(css("#festival-form"))
    end

    # F-04: 日付バリデーション
    feature "終了日が開始日より前だとエラー", %{session: session} do
      {session, _user} = register_and_login(session)

      session
      |> visit("/festivals")
      |> wait_for_liveview()
      |> click(link("新規作成"))
      |> wait_for_liveview(800)
      |> fill_in(css("#festival-form input[name='festival[name]']"), with: "日付テスト祭り")
      |> set_date_input("#festival-form input[name='festival[start_date]']", "2026-08-10")
      |> set_date_input("#festival-form input[name='festival[end_date]']", "2026-08-01")
      |> click(button("保存"))
      |> wait_for_liveview()
      # フォームが残る（バリデーションエラー）
      |> assert_has(css("#festival-form"))
    end

    # F-05: 祭り詳細表示
    feature "祭りの詳細情報を表示できる", %{session: session} do
      {session, user} = register_and_login(session)
      {session, festival_id} = create_festival_in_db(session, user, %{name: "詳細表示テスト祭り"})

      session
      |> visit("/festivals/#{festival_id}")
      |> wait_for_liveview()
      |> assert_has(css("h1", text: "詳細表示テスト祭り"))
      # <.list>はdiv.font-boldでタイトルを描画する
      |> assert_has(css("div.font-bold", text: "開催期間"))
      |> assert_has(css("div.font-bold", text: "状態"))
    end

    # F-06: 祭り編集
    feature "祭り情報を編集できる", %{session: session} do
      {session, user} = register_and_login(session)
      {_session, _festival_id} = create_festival_in_db(session, user, %{name: "編集前の祭り"})

      session
      |> visit("/festivals")
      |> wait_for_liveview()
      |> click(css("a", text: "編集", count: :any, at: 0))
      |> wait_for_liveview(800)
      |> fill_in(css("#festival-form input[name='festival[name]']"), with: "編集後の祭り")
      |> submit_form_via_js("#festival-form")
      |> wait_for_liveview(1000)
      |> assert_has(css("td", text: "編集後の祭り"))
    end

    # F-07: 祭り削除
    feature "祭りを削除できる", %{session: session} do
      {session, user} = register_and_login(session)
      {_session, _festival_id} = create_festival_in_db(session, user, %{name: "削除テスト祭り"})

      session =
        session
        |> visit("/festivals")
        |> wait_for_liveview()
        |> assert_has(css("td", text: "削除テスト祭り"))

      # accept_confirmはダイアログテキストを返す（セッションではない）
      # ブラウザの状態はsessionオブジェクト経由で維持される
      _dialog_text = accept_confirm(session, fn s ->
        click(s, css("a", text: "削除", count: :any, at: 0))
      end)

      session
      |> wait_for_liveview()
      |> refute_has(css("td", text: "削除テスト祭り"))
    end

    # F-08: ステータス変更
    feature "祭りのステータスを変更できる", %{session: session} do
      {session, user} = register_and_login(session)
      {_session, _festival_id} = create_festival_in_db(session, user)

      session
      |> visit("/festivals")
      |> wait_for_liveview()
      |> click(css("a", text: "編集", count: :any, at: 0))
      |> wait_for_liveview(800)
      |> select_option(css("#festival-form select[name='festival[status]']"), "preparation")
      |> submit_form_via_js("#festival-form")
      |> wait_for_liveview(1000)
      |> assert_has(css("td", text: "preparation"))
    end

    # F-09: 規模設定
    feature "祭りの規模を設定できる", %{session: session} do
      {session, user} = register_and_login(session)
      {_session, _festival_id} = create_festival_in_db(session, user)

      session
      |> visit("/festivals")
      |> wait_for_liveview()
      |> click(css("a", text: "編集", count: :any, at: 0))
      |> wait_for_liveview(800)
      |> select_option(css("#festival-form select[name='festival[scale]']"), "large")
      |> submit_form_via_js("#festival-form")
      |> wait_for_liveview(1000)
      |> assert_has(css("td", text: "large"))
    end
  end

  describe "祭り詳細からの遷移" do
    feature "祭り詳細からタスク管理へ遷移できる", %{session: session} do
      {session, user} = register_and_login(session)
      {session, festival_id} = create_festival_in_db(session, user)

      session
      |> visit("/festivals/#{festival_id}")
      |> wait_for_liveview()
      |> click(css("a", text: "タスク管理"))
      |> wait_for_liveview()
      |> assert_has(css("h1", text: "タスク一覧"))
    end

    feature "祭り詳細から予算管理へ遷移できる", %{session: session} do
      {session, user} = register_and_login(session)
      {session, festival_id} = create_festival_in_db(session, user)

      session
      |> visit("/festivals/#{festival_id}")
      |> wait_for_liveview()
      |> click(css("a", text: "予算管理"))
      |> wait_for_liveview()
      # 予算ページの見出しは「{festival_name} - 予算・経費管理」
      |> assert_has(css("h1", text: "予算・経費管理"))
    end
  end
end
