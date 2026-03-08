defmodule MatsuriOpsWeb.HelpLive.Staff do
  use MatsuriOpsWeb, :live_view

  alias MatsuriOpsWeb.Layouts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-4xl mx-auto">
        <.header>
          スタッフマニュアル
          <:subtitle>リーダー・スタッフ・ボランティア向け</:subtitle>
        </.header>

        <div class="mt-6 flex flex-wrap gap-2">
          <.toc_link href="#login">ログインと基本操作</.toc_link>
          <.toc_link href="#tasks">自分のタスク確認</.toc_link>
          <.toc_link href="#shifts">シフト確認</.toc_link>
          <.toc_link href="#operations">当日の操作</.toc_link>
          <.toc_link href="#chat">チャット・連絡</.toc_link>
          <.toc_link href="#announcements">お知らせ確認</.toc_link>
          <.toc_link href="#documents">ドキュメント閲覧</.toc_link>
        </div>

        <div class="mt-8 prose prose-lg max-w-none">
          <.section id="login" title="1. ログインと基本操作">
            <h4>1.1 ログイン方法</h4>
            <ol>
              <li>ブラウザでMatsuriOpsにアクセス</li>
              <li>「ログイン」をクリック</li>
              <li>メールアドレスを入力</li>
              <li>届いたメールのリンクをクリック</li>
            </ol>

            <h4>1.2 ホーム画面</h4>
            <p>ログイン後、参加している祭りの一覧が表示されます。</p>

            <h4>1.3 祭り詳細画面</h4>
            <p>祭りを選択すると、詳細画面が表示されます。ここから各機能にアクセスできます：</p>
            <ul>
              <li>タスク管理</li>
              <li>シフト管理</li>
              <li>チャット</li>
              <li>お知らせ</li>
              <li>ドキュメント</li>
            </ul>
          </.section>

          <.section id="tasks" title="2. 自分のタスク確認">
            <h4>2.1 タスク一覧を開く</h4>
            <p>祭り詳細画面から「タスク管理」をクリックします。</p>

            <h4>2.2 タスクの見方</h4>
            <div class="overflow-x-auto">
              <table class="table">
                <thead>
                  <tr>
                    <th>ステータス</th>
                    <th>意味</th>
                  </tr>
                </thead>
                <tbody>
                  <tr><td class="text-error">未着手</td><td>まだ開始していないタスク</td></tr>
                  <tr><td class="text-info">進行中</td><td>現在作業中のタスク</td></tr>
                  <tr><td class="text-success">完了</td><td>完了したタスク</td></tr>
                  <tr><td class="text-warning">保留</td><td>一時停止中のタスク</td></tr>
                  <tr><td class="text-base-content/50">中止</td><td>キャンセルされたタスク</td></tr>
                </tbody>
              </table>
            </div>

            <h4>優先度</h4>
            <div class="overflow-x-auto">
              <table class="table">
                <thead>
                  <tr>
                    <th>優先度</th>
                    <th>意味</th>
                  </tr>
                </thead>
                <tbody>
                  <tr><td class="text-error font-bold">緊急</td><td>最優先で対応</td></tr>
                  <tr><td class="text-warning font-bold">高</td><td>優先的に対応</td></tr>
                  <tr><td>中</td><td>通常の優先度</td></tr>
                  <tr><td class="text-success">低</td><td>余裕があれば対応</td></tr>
                </tbody>
              </table>
            </div>

            <h4>2.3 タスクの詳細を確認</h4>
            <p>タスクをクリックすると詳細が表示されます：</p>
            <ul>
              <li>タスクの説明</li>
              <li>期限</li>
              <li>チェックリスト</li>
              <li>サブタスク</li>
            </ul>

            <h4>2.4 タスクのステータス更新</h4>
            <p><strong>リーダーの場合:</strong></p>
            <ol>
              <li>タスクのステータスをクリック</li>
              <li>新しいステータスを選択</li>
              <li>自動的に保存されます</li>
            </ol>
            <p><strong>スタッフ・ボランティアの場合:</strong></p>
            <p>ステータスの更新には管理者への報告が必要です。</p>

            <h4>2.5 チェックリストの操作</h4>
            <p>タスク詳細画面で：</p>
            <ol>
              <li>チェックリスト項目をクリック</li>
              <li>完了/未完了が切り替わります</li>
            </ol>
          </.section>

          <.section id="shifts" title="3. シフト確認">
            <h4>3.1 シフト一覧を開く</h4>
            <p>祭り詳細画面から「シフト管理」をクリックします。</p>

            <h4>3.2 シフトの見方</h4>
            <p>シフトは日付ごとにまとめて表示されます：</p>
            <ul>
              <li>シフト名</li>
              <li>開始時刻 〜 終了時刻</li>
              <li>担当場所</li>
              <li>必要人数</li>
            </ul>

            <h4>3.3 自分のシフトを確認</h4>
            <p>自分が担当するシフトは、自分の名前が表示されています。</p>
            <div class="alert alert-warning">
              <.icon name="hero-exclamation-triangle" class="w-5 h-5" />
              <span>当日は、開始時刻までに担当場所に集合してください。</span>
            </div>
          </.section>

          <.section id="operations" title="4. 当日の操作">
            <h4>4.1 運営ダッシュボード</h4>
            <p>祭り詳細画面から「運営ダッシュボード」をクリックします。</p>
            <p>ここでは：</p>
            <ul>
              <li>現在のインシデント状況</li>
              <li>エリアの混雑状況</li>
              <li>天候情報</li>
            </ul>
            <p>が確認できます。</p>

            <h4>4.2 インシデント報告</h4>
            <p>問題が発生した場合は、すぐに報告しましょう。</p>
            <ol>
              <li>「インシデント報告」ボタンをクリック</li>
              <li>以下の情報を入力：</li>
            </ol>
            <div class="overflow-x-auto">
              <table class="table">
                <thead>
                  <tr>
                    <th>項目</th>
                    <th>入力内容</th>
                  </tr>
                </thead>
                <tbody>
                  <tr><td>タイトル</td><td>何が起きたか簡潔に</td></tr>
                  <tr><td>重大度</td><td>緊急度を選択</td></tr>
                  <tr><td>カテゴリ</td><td>種類を選択</td></tr>
                  <tr><td>場所</td><td>発生場所</td></tr>
                  <tr><td>説明</td><td>詳細な状況</td></tr>
                </tbody>
              </table>
            </div>
            <ol start="3">
              <li>「報告」をクリック</li>
            </ol>

            <h4>重大度の目安</h4>
            <div class="overflow-x-auto">
              <table class="table">
                <thead>
                  <tr>
                    <th>重大度</th>
                    <th>状況の例</th>
                  </tr>
                </thead>
                <tbody>
                  <tr><td class="text-error font-bold">緊急</td><td>救急対応が必要、火災、大規模な事故</td></tr>
                  <tr><td class="text-warning font-bold">高</td><td>けが人発生、設備の重大な故障</td></tr>
                  <tr><td>中</td><td>軽い怪我、設備の軽微な問題</td></tr>
                  <tr><td class="text-success">低</td><td>遺失物、軽微な問い合わせ</td></tr>
                </tbody>
              </table>
            </div>

            <h4>4.3 位置情報の共有</h4>
            <p>チームメンバーに自分の位置を知らせることができます。</p>
            <ol>
              <li>祭り詳細から「位置情報」をクリック</li>
              <li>「現在位置を共有」をクリック</li>
              <li>位置情報の許可を求められたら「許可」を選択</li>
            </ol>
            <div class="alert alert-info">
              <.icon name="hero-information-circle" class="w-5 h-5" />
              <span>注意: バッテリー消費が増える場合があります。</span>
            </div>

            <h4>4.4 エリア状況の確認</h4>
            <p>運営ダッシュボードでエリアの状況を確認できます：</p>
            <div class="overflow-x-auto">
              <table class="table">
                <thead>
                  <tr>
                    <th>混雑度</th>
                    <th>状況</th>
                  </tr>
                </thead>
                <tbody>
                  <tr><td>0（空き）</td><td>人がほとんどいない</td></tr>
                  <tr><td>1（閑散）</td><td>余裕がある</td></tr>
                  <tr><td>2（やや混雑）</td><td>少し混んできた</td></tr>
                  <tr><td>3（混雑）</td><td>混雑している</td></tr>
                  <tr><td>4（非常に混雑）</td><td>かなり混雑</td></tr>
                  <tr><td class="text-error">5（過密）</td><td>危険な混雑状態</td></tr>
                </tbody>
              </table>
            </div>
          </.section>

          <.section id="chat" title="5. チャット・連絡">
            <h4>5.1 チャットを開く</h4>
            <p>祭り詳細画面から「チャット」をクリックします。</p>

            <h4>5.2 チャットルームの種類</h4>
            <div class="overflow-x-auto">
              <table class="table">
                <thead>
                  <tr>
                    <th>ルーム</th>
                    <th>用途</th>
                  </tr>
                </thead>
                <tbody>
                  <tr><td>一般</td><td>全体への連絡</td></tr>
                  <tr><td class="text-error font-bold">緊急</td><td>緊急時の連絡（重要なメッセージのみ）</td></tr>
                  <tr><td>スタッフ</td><td>スタッフ間の連絡</td></tr>
                  <tr><td>出店者</td><td>出店者への連絡</td></tr>
                </tbody>
              </table>
            </div>

            <h4>5.3 メッセージの送信</h4>
            <ol>
              <li>チャットルームを選択</li>
              <li>メッセージを入力</li>
              <li>「送信」をクリック</li>
            </ol>

            <h4>5.4 注意事項</h4>
            <ul>
              <li>緊急ルームは本当に緊急な場合のみ使用</li>
              <li>個人情報は送信しない</li>
              <li>不要な雑談は控える</li>
            </ul>
          </.section>

          <.section id="announcements" title="6. お知らせ確認">
            <h4>6.1 お知らせを開く</h4>
            <p>祭り詳細画面から「お知らせ」をクリックします。</p>

            <h4>6.2 お知らせの見方</h4>
            <div class="overflow-x-auto">
              <table class="table">
                <thead>
                  <tr>
                    <th>優先度</th>
                    <th>表示</th>
                    <th>内容</th>
                  </tr>
                </thead>
                <tbody>
                  <tr><td class="text-error font-bold">緊急</td><td>赤枠</td><td>至急確認が必要</td></tr>
                  <tr><td class="text-warning font-bold">高</td><td>オレンジ枠</td><td>重要な連絡</td></tr>
                  <tr><td>通常</td><td>通常表示</td><td>一般的な連絡</td></tr>
                </tbody>
              </table>
            </div>

            <h4>6.3 プッシュ通知</h4>
            <p>お知らせはプッシュ通知でも届きます。通知を有効にしておくと、重要な連絡を見逃しません。</p>
          </.section>

          <.section id="documents" title="7. ドキュメント閲覧">
            <h4>7.1 ドキュメントを開く</h4>
            <p>祭り詳細画面から「ドキュメント」をクリックします。</p>

            <h4>7.2 ドキュメントの種類</h4>
            <div class="overflow-x-auto">
              <table class="table">
                <thead>
                  <tr>
                    <th>カテゴリ</th>
                    <th>内容</th>
                  </tr>
                </thead>
                <tbody>
                  <tr><td>マニュアル</td><td>運営マニュアル、作業手順書</td></tr>
                  <tr><td>テンプレート</td><td>報告書フォーマットなど</td></tr>
                  <tr><td>報告書</td><td>過去の報告書</td></tr>
                  <tr><td>その他</td><td>その他の資料</td></tr>
                </tbody>
              </table>
            </div>

            <h4>7.3 ドキュメントの検索</h4>
            <ol>
              <li>検索ボックスにキーワードを入力</li>
              <li>該当するドキュメントが表示されます</li>
            </ol>
          </.section>

          <.section id="faq" title="よくある質問">
            <div class="space-y-4">
              <div class="collapse collapse-arrow bg-base-200">
                <input type="checkbox" />
                <div class="collapse-title font-medium">Q: パスワードを忘れました</div>
                <div class="collapse-content">
                  <p>A: パスワードは使用していません。メールアドレスでログインすると、確認メールが届きます。</p>
                </div>
              </div>

              <div class="collapse collapse-arrow bg-base-200">
                <input type="checkbox" />
                <div class="collapse-title font-medium">Q: シフトを変更してほしい</div>
                <div class="collapse-content">
                  <p>A: リーダーまたは管理者に連絡してください。</p>
                </div>
              </div>

              <div class="collapse collapse-arrow bg-base-200">
                <input type="checkbox" />
                <div class="collapse-title font-medium">Q: インシデント報告を間違えました</div>
                <div class="collapse-content">
                  <p>A: インシデントを編集して修正するか、管理者に連絡してください。</p>
                </div>
              </div>

              <div class="collapse collapse-arrow bg-base-200">
                <input type="checkbox" />
                <div class="collapse-title font-medium">Q: 通知が届きません</div>
                <div class="collapse-content">
                  <p>A: ブラウザの通知設定を確認してください。また、PWAとしてインストールすると通知を受け取りやすくなります。</p>
                </div>
              </div>

              <div class="collapse collapse-arrow bg-base-200">
                <input type="checkbox" />
                <div class="collapse-title font-medium">Q: アプリが動かなくなりました</div>
                <div class="collapse-content">
                  <p>A: ブラウザを再読み込み（F5 または Cmd+R）してください。</p>
                </div>
              </div>
            </div>
          </.section>

          <.section id="emergency" title="緊急連絡先">
            <p>問題が発生した場合は、以下に連絡してください：</p>
            <div class="overflow-x-auto">
              <table class="table">
                <thead>
                  <tr>
                    <th>状況</th>
                    <th>連絡先</th>
                  </tr>
                </thead>
                <tbody>
                  <tr><td>運営に関する問題</td><td>リーダーまたは事務局</td></tr>
                  <tr><td>システムに関する問題</td><td>システム管理者</td></tr>
                  <tr><td>緊急事態</td><td>緊急チャットルーム</td></tr>
                </tbody>
              </table>
            </div>
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

  defp toc_link(assigns) do
    ~H"""
    <a href={@href} class="badge badge-outline hover:badge-primary transition-colors">
      {render_slot(@inner_block)}
    </a>
    """
  end

  defp section(assigns) do
    ~H"""
    <div id={@id} class="mt-8 pb-8 border-b border-base-300 last:border-b-0 scroll-mt-20">
      <h2 class="text-2xl font-bold mb-4">{@title}</h2>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
