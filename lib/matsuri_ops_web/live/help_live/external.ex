defmodule MatsuriOpsWeb.HelpLive.External do
  use MatsuriOpsWeb, :live_view

  alias MatsuriOpsWeb.Layouts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-4xl mx-auto">
        <.header>
          出店者・来場者ガイド
          <:subtitle>外部ユーザー向けの簡易ガイド</:subtitle>
        </.header>

        <div class="mt-6 flex flex-wrap gap-2">
          <.toc_link href="#registration">アカウント登録</.toc_link>
          <.toc_link href="#festival-info">祭り情報の確認</.toc_link>
          <.toc_link href="#notifications">お知らせの受信</.toc_link>
          <.toc_link href="#contact">連絡先・問い合わせ</.toc_link>
          <.toc_link href="#vendor">出店者向け情報</.toc_link>
          <.toc_link href="#mobile">スマートフォンでの利用</.toc_link>
        </div>

        <div class="mt-8 prose prose-lg max-w-none">
          <.section id="registration" title="1. アカウント登録">
            <h4>1.1 登録方法</h4>
            <ol>
              <li>ブラウザでMatsuriOpsにアクセス</li>
              <li>「新規登録」をクリック</li>
              <li>メールアドレスを入力</li>
              <li>「登録」をクリック</li>
            </ol>

            <h4>1.2 ログイン</h4>
            <ol>
              <li>「ログイン」をクリック</li>
              <li>メールアドレスを入力</li>
              <li>届いたメールのリンクをクリック</li>
            </ol>

            <h4>1.3 プロフィール設定</h4>
            <p>ログイン後、右上のメニューから「Settings」を選択：</p>
            <p>以下の情報を入力できます：</p>
            <ul>
              <li>名前（表示名）</li>
              <li>電話番号</li>
              <li>所属（店舗名など）</li>
            </ul>
          </.section>

          <.section id="festival-info" title="2. 祭り情報の確認">
            <h4>2.1 祭り一覧</h4>
            <p>ログイン後、参加している祭りの一覧が表示されます。</p>

            <h4>2.2 祭り詳細</h4>
            <p>祭りを選択すると、詳細情報が確認できます：</p>
            <ul>
              <li>祭りの名称</li>
              <li>開催日程</li>
              <li>開催場所</li>
              <li>規模・来場予想</li>
            </ul>
          </.section>

          <.section id="notifications" title="3. お知らせの受信">
            <h4>3.1 お知らせの確認</h4>
            <p>祭り詳細画面から「お知らせ」をクリックします。</p>

            <h4>3.2 お知らせの種類</h4>
            <div class="overflow-x-auto">
              <table class="table">
                <thead>
                  <tr>
                    <th>優先度</th>
                    <th>表示</th>
                    <th>対応</th>
                  </tr>
                </thead>
                <tbody>
                  <tr><td class="text-error font-bold">緊急</td><td>赤枠</td><td>すぐに確認してください</td></tr>
                  <tr><td class="text-warning font-bold">高</td><td>オレンジ枠</td><td>早めに確認してください</td></tr>
                  <tr><td>通常</td><td>通常表示</td><td>随時確認してください</td></tr>
                </tbody>
              </table>
            </div>

            <h4>3.3 プッシュ通知の設定</h4>
            <p>重要なお知らせをリアルタイムで受け取るには：</p>
            <p><strong>スマートフォンの場合:</strong></p>
            <ol>
              <li>MatsuriOpsをホーム画面に追加（PWAインストール）</li>
              <li>通知の許可を求められたら「許可」を選択</li>
            </ol>
            <p><strong>パソコンの場合:</strong></p>
            <ol>
              <li>ブラウザで通知を許可</li>
              <li>通知設定をオンにする</li>
            </ol>
          </.section>

          <.section id="contact" title="4. 連絡先・問い合わせ">
            <h4>4.1 チャットでの連絡</h4>
            <p>祭り詳細画面から「チャット」をクリックします。</p>
            <p><strong>出店者の場合:</strong></p>
            <p>「出店者」ルームで運営スタッフに連絡できます。</p>

            <h4>4.2 お問い合わせ</h4>
            <p>以下の内容は、チャットまたは運営スタッフに直接お問い合わせください：</p>
            <div class="overflow-x-auto">
              <table class="table">
                <thead>
                  <tr>
                    <th>内容</th>
                    <th>連絡先</th>
                  </tr>
                </thead>
                <tbody>
                  <tr><td>出店に関する質問</td><td>出店者チャットルーム</td></tr>
                  <tr><td>当日の緊急連絡</td><td>緊急チャットルーム</td></tr>
                  <tr><td>システムの問題</td><td>事務局</td></tr>
                </tbody>
              </table>
            </div>

            <h4>4.3 よくある質問</h4>
            <div class="space-y-4">
              <div class="collapse collapse-arrow bg-base-200">
                <input type="checkbox" />
                <div class="collapse-title font-medium">Q: ログインできません</div>
                <div class="collapse-content">
                  <p>A: メールアドレスが正しいか確認してください。メールが届かない場合は、迷惑メールフォルダを確認してください。</p>
                </div>
              </div>

              <div class="collapse collapse-arrow bg-base-200">
                <input type="checkbox" />
                <div class="collapse-title font-medium">Q: お知らせが見られません</div>
                <div class="collapse-content">
                  <p>A: 祭りに参加者として登録されているか、運営スタッフに確認してください。</p>
                </div>
              </div>

              <div class="collapse collapse-arrow bg-base-200">
                <input type="checkbox" />
                <div class="collapse-title font-medium">Q: 通知が届きません</div>
                <div class="collapse-content">
                  <p>A: ブラウザの通知設定を確認してください。PWAとしてインストールすると、通知を受け取りやすくなります。</p>
                </div>
              </div>
            </div>
          </.section>

          <.section id="vendor" title="出店者向け情報">
            <h4>出店準備</h4>
            <ol>
              <li>祭り詳細画面で出店に関するお知らせを確認</li>
              <li>必要なドキュメントを「ドキュメント」から取得</li>
              <li>不明点はチャットで質問</li>
            </ol>

            <h4>当日の流れ</h4>
            <ol>
              <li>指定の時間に会場に到着</li>
              <li>受付で出店者登録</li>
              <li>指定のエリアで設営</li>
              <li>お知らせで最新情報を確認</li>
            </ol>

            <h4>緊急時の対応</h4>
            <p>問題が発生した場合：</p>
            <ol>
              <li>近くのスタッフに声をかける</li>
              <li>緊急チャットルームに報告</li>
              <li>指示に従って行動</li>
            </ol>
          </.section>

          <.section id="mobile" title="スマートフォンでの利用">
            <h4>PWAインストール方法</h4>
            <p>MatsuriOpsはPWA（Progressive Web App）に対応しています。ホーム画面に追加すると、アプリのように使えます。</p>

            <div class="grid md:grid-cols-2 gap-6 mt-4">
              <div class="card bg-base-200">
                <div class="card-body">
                  <h5 class="card-title flex items-center gap-2">
                    <.icon name="hero-device-phone-mobile" class="w-5 h-5" />
                    iPhoneの場合
                  </h5>
                  <ol class="list-decimal list-inside">
                    <li>Safariでアクセス</li>
                    <li>画面下の「共有」ボタンをタップ</li>
                    <li>「ホーム画面に追加」を選択</li>
                    <li>「追加」をタップ</li>
                  </ol>
                </div>
              </div>

              <div class="card bg-base-200">
                <div class="card-body">
                  <h5 class="card-title flex items-center gap-2">
                    <.icon name="hero-device-phone-mobile" class="w-5 h-5" />
                    Androidの場合
                  </h5>
                  <ol class="list-decimal list-inside">
                    <li>Chromeでアクセス</li>
                    <li>画面右上のメニューをタップ</li>
                    <li>「ホーム画面に追加」を選択</li>
                    <li>「追加」をタップ</li>
                  </ol>
                </div>
              </div>
            </div>

            <h4 class="mt-6">PWAの利点</h4>
            <ul>
              <li>アプリのようにすぐにアクセス</li>
              <li>プッシュ通知を受け取れる</li>
              <li>オフラインでも一部の機能が使える</li>
            </ul>
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
