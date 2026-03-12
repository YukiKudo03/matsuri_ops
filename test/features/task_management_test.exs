defmodule MatsuriOpsWeb.Features.TaskManagementTest do
  @moduledoc """
  タスク管理機能のE2Eテスト (Suite 5: T-01〜T-11)
  """

  use MatsuriOpsWeb.FeatureCase, async: false

  setup %{session: session} do
    {session, user} = register_and_login(session)
    {session, festival_id} = create_festival_in_db(session, user, %{name: "タスクテスト祭り"})
    {:ok, session: session, user: user, festival_id: festival_id}
  end

  # タスク一覧ページで「新規タスク」ボタンをクリックしてモーダルを開く
  defp open_new_task_modal(session, festival_id) do
    session
    |> visit("/festivals/#{festival_id}/tasks")
    |> wait_for_liveview()
    |> click(link("新規タスク"))
    |> wait_for_liveview(800)
  end

  # タスクを作成して一覧に戻るヘルパー
  defp create_task(session, festival_id, title) do
    session
    |> open_new_task_modal(festival_id)
    |> fill_in(css("#task-form input[name='task[title]']"), with: title)
    |> click(button("保存"))
    |> wait_for_liveview(800)
  end

  describe "タスク一覧" do
    # T-01: タスク一覧表示
    feature "タスク一覧を表示できる", %{session: session, festival_id: festival_id} do
      session
      |> visit("/festivals/#{festival_id}/tasks")
      |> wait_for_liveview()
      |> assert_has(css("h1", text: "タスク一覧"))
    end
  end

  describe "タスクCRUD操作" do
    # T-02: タスク新規作成
    feature "タスクを新規作成できる", %{session: session, festival_id: festival_id} do
      task_title = "会場設営#{System.unique_integer([:positive])}"

      session
      |> create_task(festival_id, task_title)
      |> assert_has(css("td", text: task_title))
    end

    # T-03: 必須項目バリデーション
    feature "タイトル未入力で保存するとエラー", %{session: session, festival_id: festival_id} do
      session
      |> open_new_task_modal(festival_id)
      |> click(button("保存"))
      |> wait_for_liveview()
      |> assert_has(css("#task-form"))
    end

    # T-04: タスク詳細表示
    feature "タスクの詳細を表示できる", %{session: session, festival_id: festival_id} do
      # タスクをDBに直接作成して詳細ページに遷移
      import Ecto.Query, only: [from: 2]

      session
      |> create_task(festival_id, "詳細表示テストタスク")

      task =
        from(t in MatsuriOps.Tasks.Task,
          where: t.title == "詳細表示テストタスク",
          order_by: [desc: t.inserted_at],
          limit: 1
        )
        |> MatsuriOps.Repo.one!()

      session
      |> visit("/festivals/#{festival_id}/tasks/#{task.id}")
      |> wait_for_liveview()
      |> assert_has(css("h1", text: "詳細表示テストタスク"))
      # <.list>はdiv.font-boldでタイトルを描画する
      |> assert_has(css("div.font-bold", text: "状態"))
      |> assert_has(css("div.font-bold", text: "優先度"))
    end

    # T-05: タスク編集
    feature "タスクを編集できる", %{session: session, festival_id: festival_id} do
      session =
        session
        |> create_task(festival_id, "編集前タスク")

      # 一覧ページを再読み込みして安定した状態で編集
      session
      |> visit("/festivals/#{festival_id}/tasks")
      |> wait_for_liveview()
      |> click(css("a[href*='edit']"))
      |> wait_for_liveview(800)
      |> fill_in(css("#task-form input[name='task[title]']"), with: "編集後タスク")
      |> click(button("保存"))
      |> wait_for_liveview(1000)
      |> visit("/festivals/#{festival_id}/tasks")
      |> wait_for_liveview()
      |> assert_has(css("td", text: "編集後タスク"))
    end

    # T-06: ステータス変更
    feature "タスクのステータスを変更できる", %{session: session, festival_id: festival_id} do
      session =
        session
        |> create_task(festival_id, "ステータス変更テスト")

      session
      |> visit("/festivals/#{festival_id}/tasks")
      |> wait_for_liveview()
      |> click(css("a[href*='edit']"))
      |> wait_for_liveview(800)
      |> select_option(css("#task-form select[name='task[status]']"), "in_progress")
      |> click(button("保存"))
      |> wait_for_liveview(1000)
      |> visit("/festivals/#{festival_id}/tasks")
      |> wait_for_liveview()
      |> assert_has(css("span", text: "進行中"))
    end

    # T-07: 優先度変更
    feature "タスクの優先度を変更できる", %{session: session, festival_id: festival_id} do
      session =
        session
        |> create_task(festival_id, "優先度変更テスト")

      session
      |> visit("/festivals/#{festival_id}/tasks")
      |> wait_for_liveview()
      |> click(css("a[href*='edit']"))
      |> wait_for_liveview(800)
      |> select_option(css("#task-form select[name='task[priority]']"), "urgent")
      |> click(button("保存"))
      |> wait_for_liveview(1000)
      |> visit("/festivals/#{festival_id}/tasks")
      |> wait_for_liveview()
      |> assert_has(css("span", text: "緊急"))
    end

    # T-09: 進捗率更新
    feature "タスクの進捗率を更新できる", %{session: session, festival_id: festival_id} do
      session
      |> open_new_task_modal(festival_id)
      |> fill_in(css("#task-form input[name='task[title]']"), with: "進捗更新テスト")
      |> fill_in(css("#task-form input[name='task[progress_percent]']"), with: "75")
      |> click(button("保存"))
      |> wait_for_liveview(800)
      |> assert_has(css("td", text: "75%"))
    end

    # T-10: マイルストーン設定
    feature "タスクをマイルストーンに設定できる", %{session: session, festival_id: festival_id} do
      session
      |> open_new_task_modal(festival_id)
      |> fill_in(css("#task-form input[name='task[title]']"), with: "マイルストーンテスト")
      |> click(css("#task-form input[name='task[is_milestone]']"))
      |> click(button("保存"))
      |> wait_for_liveview(800)
      |> click(css("td", text: "マイルストーンテスト"))
      |> wait_for_liveview()
      |> assert_has(css("span", text: "⭐"))
    end

    # T-11: タスク削除
    feature "タスクを削除できる", %{session: session, festival_id: festival_id} do
      task_title = "削除テストタスク#{System.unique_integer([:positive])}"

      session =
        session
        |> create_task(festival_id, task_title)
        |> assert_has(css("td", text: task_title))

      # DBからタスクIDを取得してliveSocket経由でdeleteイベントをPush
      import Ecto.Query, only: [from: 2]

      task =
        from(t in MatsuriOps.Tasks.Task,
          where: t.title == ^task_title,
          limit: 1
        )
        |> MatsuriOps.Repo.one!()

      session
      |> push_liveview_event("delete", %{"id" => task.id})
      |> wait_for_liveview(2000)
      |> visit("/festivals/#{festival_id}/tasks")
      |> wait_for_liveview()
      |> refute_has(css("td", text: task_title))
    end
  end
end
