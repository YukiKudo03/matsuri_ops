defmodule MatsuriOpsWeb.HelpLive.Quickstart do
  use MatsuriOpsWeb, :live_view

  alias MatsuriOpsWeb.Layouts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-4xl mx-auto">
        <.header>
          クイックスタートガイド
          <:subtitle>5分で始められる基本操作ガイド</:subtitle>
        </.header>

        <div class="mt-8 prose prose-lg max-w-none">
          <.section title="MatsuriOpsとは">
            <p>
              MatsuriOpsは、地域の祭りやイベントの運営を効率化するWebアプリケーションです。
            </p>
            <h4>主な機能</h4>
            <ul>
              <li>祭り情報の一元管理</li>
              <li>タスク・スケジュール管理</li>
              <li>予算・経費管理</li>
              <li>スタッフ配置・シフト管理</li>
              <li>当日の運営支援（インシデント対応、エリア監視）</li>
              <li>リアルタイムコミュニケーション</li>
            </ul>

            <h4>動作環境</h4>
            <div class="overflow-x-auto">
              <table class="table">
                <thead>
                  <tr>
                    <th>環境</th>
                    <th>対応状況</th>
                  </tr>
                </thead>
                <tbody>
                  <tr><td>Chrome（推奨）</td><td>対応</td></tr>
                  <tr><td>Safari</td><td>対応</td></tr>
                  <tr><td>Firefox</td><td>対応</td></tr>
                  <tr><td>Edge</td><td>対応</td></tr>
                  <tr><td>スマートフォン</td><td>対応（PWA対応）</td></tr>
                </tbody>
              </table>
            </div>
          </.section>

          <.section title="Step 1: アカウント登録（2分）">
            <h4>1.1 登録画面へアクセス</h4>
            <p>ブラウザでMatsuriOpsのURLを開き、「新規登録」をクリックします。</p>

            <h4>1.2 メールアドレスを入力</h4>
            <ol>
              <li>メールアドレスを入力</li>
              <li>「登録」ボタンをクリック</li>
            </ol>

            <h4>1.3 確認メールからログイン</h4>
            <ol>
              <li>入力したメールアドレスに確認メールが届きます</li>
              <li>メール内のリンクをクリックしてログイン完了</li>
            </ol>

            <div class="alert alert-info">
              <.icon name="hero-light-bulb" class="w-5 h-5" />
              <span>ヒント: メールが届かない場合は、迷惑メールフォルダを確認してください。</span>
            </div>
          </.section>

          <.section title="Step 2: プロフィール設定（1分）">
            <h4>2.1 設定画面へ移動</h4>
            <p>ログイン後、右上のメニューから「Settings」を選択します。</p>

            <h4>2.2 基本情報を入力</h4>
            <p>以下の情報を入力して「保存」をクリック：</p>
            <div class="overflow-x-auto">
              <table class="table">
                <thead>
                  <tr>
                    <th>項目</th>
                    <th>説明</th>
                  </tr>
                </thead>
                <tbody>
                  <tr><td>名前</td><td>表示名（他のユーザーに見える名前）</td></tr>
                  <tr><td>電話番号</td><td>緊急連絡用</td></tr>
                  <tr><td>所属</td><td>組織・団体名</td></tr>
                  <tr><td>緊急連絡先</td><td>緊急時の連絡先</td></tr>
                  <tr><td>スキル</td><td>担当可能な作業（設営、運営など）</td></tr>
                </tbody>
              </table>
            </div>
          </.section>

          <.section title="Step 3: 祭りに参加/作成（2分）">
            <h4>3.1 祭り一覧を確認</h4>
            <p>ログイン後、祭り一覧ページが表示されます。</p>

            <h4>3.2 既存の祭りに参加する場合</h4>
            <ol>
              <li>一覧から参加したい祭りをクリック</li>
              <li>管理者から招待を受けている場合、メンバーとして追加されます</li>
            </ol>

            <h4>3.3 新しい祭りを作成する場合</h4>
            <ol>
              <li>「新規作成」ボタンをクリック</li>
              <li>祭り情報を入力：
                <ul>
                  <li>祭り名（必須）</li>
                  <li>開催日（開始日・終了日）</li>
                  <li>会場名・住所</li>
                  <li>規模（小規模/中規模/大規模）</li>
                  <li>予想来場者数・出店数</li>
                </ul>
              </li>
              <li>「作成」をクリックして完了</li>
            </ol>
          </.section>

          <.section title="次のステップ">
            <p>基本設定が完了しました。次のステップへ進みましょう：</p>

            <h4>ロール別ガイド</h4>
            <div class="overflow-x-auto">
              <table class="table">
                <thead>
                  <tr>
                    <th>あなたのロール</th>
                    <th>参照するマニュアル</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>システム管理者・実行委員・事務局</td>
                    <td><.link navigate={~p"/help/admin"} class="link link-primary">管理者マニュアル</.link></td>
                  </tr>
                  <tr>
                    <td>リーダー・スタッフ・ボランティア</td>
                    <td><.link navigate={~p"/help/staff"} class="link link-primary">スタッフマニュアル</.link></td>
                  </tr>
                  <tr>
                    <td>出店者・来場者</td>
                    <td><.link navigate={~p"/help/external"} class="link link-primary">外部ユーザーガイド</.link></td>
                  </tr>
                </tbody>
              </table>
            </div>

            <h4>よく使う機能</h4>
            <div class="overflow-x-auto">
              <table class="table">
                <thead>
                  <tr>
                    <th>やりたいこと</th>
                    <th>操作方法</th>
                  </tr>
                </thead>
                <tbody>
                  <tr><td>タスクを確認したい</td><td>祭り詳細 → 「タスク管理」</td></tr>
                  <tr><td>シフトを確認したい</td><td>祭り詳細 → 「シフト管理」</td></tr>
                  <tr><td>お知らせを見たい</td><td>祭り詳細 → 「お知らせ」</td></tr>
                  <tr><td>連絡したい</td><td>祭り詳細 → 「チャット」</td></tr>
                </tbody>
              </table>
            </div>
          </.section>

          <.section title="トラブルシューティング">
            <h4>ログインできない</h4>
            <ol>
              <li>メールアドレスが正しいか確認</li>
              <li>迷惑メールフォルダを確認</li>
              <li>再度「ログイン」から手続きをやり直す</li>
            </ol>

            <h4>画面が正しく表示されない</h4>
            <ol>
              <li>ブラウザを最新版に更新</li>
              <li>キャッシュをクリア（Ctrl+Shift+R または Cmd+Shift+R）</li>
              <li>別のブラウザで試す</li>
            </ol>

            <h4>その他の問題</h4>
            <p>管理者またはサポートに連絡してください。</p>
          </.section>

          <.section title="PWAとしてインストール">
            <p>スマートフォンでMatsuriOpsをアプリのように使うことができます。</p>

            <h4>iPhoneの場合</h4>
            <ol>
              <li>Safariでアクセス</li>
              <li>共有ボタンをタップ</li>
              <li>「ホーム画面に追加」を選択</li>
            </ol>

            <h4>Androidの場合</h4>
            <ol>
              <li>Chromeでアクセス</li>
              <li>メニューをタップ</li>
              <li>「ホーム画面に追加」を選択</li>
            </ol>
          </.section>
        </div>

        <.back navigate={~p"/help"}>ヘルプトップに戻る</.back>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  defp section(assigns) do
    ~H"""
    <div class="mt-8 pb-8 border-b border-base-300 last:border-b-0">
      <h2 class="text-2xl font-bold mb-4">{@title}</h2>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
