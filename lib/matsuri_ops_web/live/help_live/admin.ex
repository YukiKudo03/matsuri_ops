defmodule MatsuriOpsWeb.HelpLive.Admin do
  use MatsuriOpsWeb, :live_view

  alias MatsuriOpsWeb.Layouts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-4xl mx-auto">
        <.header>
          管理者マニュアル
          <:subtitle>システム管理者・実行委員・事務局向け</:subtitle>
        </.header>

        <div class="mt-6 flex flex-wrap gap-2">
          <.toc_link href="#system-overview">システム概要</.toc_link>
          <.toc_link href="#user-management">ユーザー管理</.toc_link>
          <.toc_link href="#festival-management">祭り管理</.toc_link>
          <.toc_link href="#task-management">タスク管理</.toc_link>
          <.toc_link href="#budget-management">予算管理</.toc_link>
          <.toc_link href="#shift-management">シフト管理</.toc_link>
          <.toc_link href="#operations">当日運営</.toc_link>
          <.toc_link href="#reports">レポート・分析</.toc_link>
          <.toc_link href="#other-features">その他の機能</.toc_link>
        </div>

        <div class="mt-8 prose prose-lg max-w-none">
          <.section id="system-overview" title="1. システム概要">
            <h4>1.1 ユーザーロール</h4>
            <div class="overflow-x-auto">
              <table class="table">
                <thead>
                  <tr>
                    <th>ロール</th>
                    <th>権限レベル</th>
                    <th>主な操作</th>
                  </tr>
                </thead>
                <tbody>
                  <tr><td>システム管理者</td><td>最高</td><td>全機能</td></tr>
                  <tr><td>実行委員</td><td>高</td><td>祭り管理、スタッフ管理</td></tr>
                  <tr><td>事務局</td><td>高</td><td>祭り管理、予算管理</td></tr>
                  <tr><td>リーダー</td><td>中</td><td>タスク管理、スタッフ指示</td></tr>
                  <tr><td>スタッフ</td><td>低</td><td>タスク確認、報告</td></tr>
                  <tr><td>ボランティア</td><td>低</td><td>タスク確認</td></tr>
                  <tr><td>出店者</td><td>限定</td><td>自分の出店情報</td></tr>
                  <tr><td>来場者</td><td>限定</td><td>情報閲覧</td></tr>
                </tbody>
              </table>
            </div>

            <h4>1.2 画面構成</h4>
            <p>メイン画面から各機能にアクセスできます：</p>
            <ul>
              <li>祭り一覧
                <ul>
                  <li>祭り詳細
                    <ul>
                      <li>タスク管理</li>
                      <li>予算管理</li>
                      <li>スタッフ管理</li>
                      <li>シフト管理</li>
                      <li>運営ダッシュボード</li>
                      <li>チャット</li>
                      <li>お知らせ</li>
                      <li>ドキュメント</li>
                      <li>レポート</li>
                      <li>ガントチャート</li>
                    </ul>
                  </li>
                </ul>
              </li>
            </ul>
          </.section>

          <.section id="user-management" title="2. ユーザー管理">
            <h4>2.1 スタッフの追加</h4>
            <ol>
              <li>祭り詳細画面を開く</li>
              <li>「スタッフ管理」をクリック</li>
              <li>「スタッフ追加」ボタンをクリック</li>
              <li>以下の情報を入力：
                <ul>
                  <li>メールアドレス（必須）</li>
                  <li>ロール（実行委員/事務局/リーダー/スタッフ/ボランティア/出店者）</li>
                  <li>担当エリア</li>
                  <li>備考</li>
                </ul>
              </li>
              <li>「追加」をクリック</li>
            </ol>

            <h4>2.2 ロールの変更</h4>
            <ol>
              <li>スタッフ一覧から対象者を選択</li>
              <li>「編集」をクリック</li>
              <li>ロールを変更して保存</li>
            </ol>

            <h4>2.3 スタッフの削除</h4>
            <ol>
              <li>スタッフ一覧から対象者を選択</li>
              <li>「削除」をクリック</li>
              <li>確認ダイアログで「削除」を選択</li>
            </ol>
          </.section>

          <.section id="festival-management" title="3. 祭り管理">
            <h4>3.1 祭りの作成</h4>
            <ol>
              <li>祭り一覧画面で「新規作成」をクリック</li>
              <li>基本情報を入力：</li>
            </ol>
            <div class="overflow-x-auto">
              <table class="table">
                <thead>
                  <tr>
                    <th>項目</th>
                    <th>説明</th>
                    <th>必須</th>
                  </tr>
                </thead>
                <tbody>
                  <tr><td>祭り名</td><td>イベントの名称</td><td>必須</td></tr>
                  <tr><td>説明</td><td>イベントの概要</td><td></td></tr>
                  <tr><td>開始日</td><td>開催開始日</td><td>必須</td></tr>
                  <tr><td>終了日</td><td>開催終了日</td><td>必須</td></tr>
                  <tr><td>会場名</td><td>開催場所の名称</td><td></td></tr>
                  <tr><td>会場住所</td><td>開催場所の住所</td><td></td></tr>
                  <tr><td>規模</td><td>小規模/中規模/大規模</td><td></td></tr>
                  <tr><td>予想来場者数</td><td>見込み来場者数</td><td></td></tr>
                  <tr><td>予想出店数</td><td>見込み出店者数</td><td></td></tr>
                </tbody>
              </table>
            </div>
            <ol start="3">
              <li>「作成」をクリック</li>
            </ol>

            <h4>3.2 祭りのステータス</h4>
            <div class="overflow-x-auto">
              <table class="table">
                <thead>
                  <tr>
                    <th>ステータス</th>
                    <th>説明</th>
                  </tr>
                </thead>
                <tbody>
                  <tr><td>企画中</td><td>準備開始前</td></tr>
                  <tr><td>準備中</td><td>準備作業中</td></tr>
                  <tr><td>開催中</td><td>当日運営中</td></tr>
                  <tr><td>完了</td><td>終了後</td></tr>
                  <tr><td>中止</td><td>中止された場合</td></tr>
                </tbody>
              </table>
            </div>

            <h4>3.3 テンプレートの活用</h4>
            <p><strong>テンプレートから祭りを作成:</strong></p>
            <ol>
              <li>「テンプレート」メニューを開く</li>
              <li>使用するテンプレートを選択</li>
              <li>「このテンプレートを使用」をクリック</li>
              <li>祭り名と日程を入力</li>
              <li>「作成」をクリック</li>
            </ol>

            <p><strong>祭りからテンプレートを作成:</strong></p>
            <ol>
              <li>祭り詳細画面を開く</li>
              <li>「テンプレートとして保存」をクリック</li>
              <li>テンプレート名を入力</li>
              <li>「保存」をクリック</li>
            </ol>
          </.section>

          <.section id="task-management" title="4. タスク管理">
            <h4>4.1 タスク一覧</h4>
            <p>祭り詳細から「タスク管理」をクリックすると、タスク一覧が表示されます。</p>

            <h4>4.2 タスクの作成</h4>
            <ol>
              <li>「新規タスク」ボタンをクリック</li>
              <li>タスク情報を入力：</li>
            </ol>
            <div class="overflow-x-auto">
              <table class="table">
                <thead>
                  <tr>
                    <th>項目</th>
                    <th>説明</th>
                  </tr>
                </thead>
                <tbody>
                  <tr><td>タイトル</td><td>タスク名（必須）</td></tr>
                  <tr><td>説明</td><td>詳細な内容</td></tr>
                  <tr><td>カテゴリ</td><td>タスクの分類</td></tr>
                  <tr><td>ステータス</td><td>未着手/進行中/完了/保留/中止</td></tr>
                  <tr><td>優先度</td><td>低/中/高/緊急</td></tr>
                  <tr><td>開始日</td><td>作業開始予定日</td></tr>
                  <tr><td>期限</td><td>完了予定日</td></tr>
                  <tr><td>見積時間</td><td>予想作業時間</td></tr>
                  <tr><td>進捗率</td><td>0-100%</td></tr>
                  <tr><td>マイルストーン</td><td>重要タスクとしてマーク</td></tr>
                </tbody>
              </table>
            </div>
            <ol start="3">
              <li>「作成」をクリック</li>
            </ol>

            <h4>4.3 ガントチャート</h4>
            <ol>
              <li>祭り詳細から「ガントチャート」をクリック</li>
              <li>タスクの期間が視覚的に表示されます</li>
            </ol>
          </.section>

          <.section id="budget-management" title="5. 予算管理">
            <h4>5.1 予算ダッシュボード</h4>
            <p>祭り詳細から「予算管理」をクリックすると、予算の概要が表示されます。</p>
            <p><strong>表示される情報:</strong></p>
            <ul>
              <li>総予算</li>
              <li>支出合計</li>
              <li>残予算</li>
              <li>カテゴリ別予算と執行状況</li>
            </ul>

            <h4>5.2 予算カテゴリの設定</h4>
            <ol>
              <li>「カテゴリ追加」をクリック</li>
              <li>カテゴリ情報を入力：
                <ul>
                  <li>カテゴリ名（必須）</li>
                  <li>説明</li>
                  <li>予算額（必須）</li>
                  <li>表示順</li>
                </ul>
              </li>
              <li>「保存」をクリック</li>
            </ol>

            <h4>5.3 経費の登録</h4>
            <ol>
              <li>「経費登録」ボタンをクリック</li>
              <li>経費情報を入力：</li>
            </ol>
            <div class="overflow-x-auto">
              <table class="table">
                <thead>
                  <tr>
                    <th>項目</th>
                    <th>説明</th>
                  </tr>
                </thead>
                <tbody>
                  <tr><td>件名</td><td>経費の名称（必須）</td></tr>
                  <tr><td>説明</td><td>詳細な内容</td></tr>
                  <tr><td>カテゴリ</td><td>予算カテゴリを選択</td></tr>
                  <tr><td>金額</td><td>支出額（必須）</td></tr>
                  <tr><td>数量</td><td>購入数量</td></tr>
                  <tr><td>単価</td><td>1個あたりの価格</td></tr>
                  <tr><td>支出日</td><td>実際の支出日</td></tr>
                  <tr><td>支払方法</td><td>現金/振込/クレジット/その他</td></tr>
                  <tr><td>領収書番号</td><td>管理用番号</td></tr>
                  <tr><td>備考</td><td>その他の情報</td></tr>
                </tbody>
              </table>
            </div>
            <ol start="3">
              <li>「登録」をクリック</li>
            </ol>

            <h4>5.4 経費の承認</h4>
            <ol>
              <li>経費一覧で承認待ちの経費を確認</li>
              <li>内容を確認して「承認」をクリック</li>
              <li>承認されると予算から差し引かれます</li>
            </ol>
          </.section>

          <.section id="shift-management" title="6. シフト管理">
            <h4>6.1 シフト一覧</h4>
            <p>祭り詳細から「シフト管理」をクリックすると、日付別にシフトが表示されます。</p>

            <h4>6.2 シフトの作成</h4>
            <ol>
              <li>「新規シフト」ボタンをクリック</li>
              <li>シフト情報を入力：</li>
            </ol>
            <div class="overflow-x-auto">
              <table class="table">
                <thead>
                  <tr>
                    <th>項目</th>
                    <th>説明</th>
                  </tr>
                </thead>
                <tbody>
                  <tr><td>シフト名</td><td>担当業務名</td></tr>
                  <tr><td>開始時刻</td><td>シフト開始時刻</td></tr>
                  <tr><td>終了時刻</td><td>シフト終了時刻</td></tr>
                  <tr><td>場所</td><td>担当場所</td></tr>
                  <tr><td>必要人数</td><td>必要なスタッフ数</td></tr>
                  <tr><td>説明</td><td>業務内容の詳細</td></tr>
                </tbody>
              </table>
            </div>
            <ol start="3">
              <li>「作成」をクリック</li>
            </ol>
          </.section>

          <.section id="operations" title="7. 当日運営">
            <h4>7.1 運営ダッシュボード</h4>
            <p>祭り詳細から「運営ダッシュボード」をクリックすると、リアルタイムの運営状況が表示されます。</p>
            <p><strong>表示される情報:</strong></p>
            <ul>
              <li>インシデント統計（全体/重大/中程度/解決済）</li>
              <li>エリア別混雑状況</li>
              <li>対応中インシデント一覧</li>
            </ul>

            <h4>7.2 エリアの追加</h4>
            <ol>
              <li>「エリア追加」ボタンをクリック</li>
              <li>エリア情報を入力：
                <ul>
                  <li>エリア名（必須）</li>
                  <li>混雑度（0-5）</li>
                  <li>気温</li>
                  <li>WBGT（暑さ指数）</li>
                  <li>備考</li>
                </ul>
              </li>
              <li>「保存」をクリック</li>
            </ol>

            <h4>7.3 インシデント報告</h4>
            <ol>
              <li>「インシデント報告」ボタンをクリック</li>
              <li>インシデント情報を入力：</li>
            </ol>
            <div class="overflow-x-auto">
              <table class="table">
                <thead>
                  <tr>
                    <th>項目</th>
                    <th>説明</th>
                  </tr>
                </thead>
                <tbody>
                  <tr><td>タイトル</td><td>インシデントの概要（必須）</td></tr>
                  <tr><td>説明</td><td>詳細な状況</td></tr>
                  <tr><td>重大度</td><td>低/中/高/緊急</td></tr>
                  <tr><td>カテゴリ</td><td>医療/セキュリティ/遺失物/天候/設備/その他</td></tr>
                  <tr><td>場所</td><td>発生場所</td></tr>
                  <tr><td>ステータス</td><td>報告済/確認中/対応中/解決/クローズ</td></tr>
                </tbody>
              </table>
            </div>
            <ol start="3">
              <li>「報告」をクリック</li>
            </ol>

            <h4>7.4 インシデント対応</h4>
            <ol>
              <li>インシデントカードをクリック</li>
              <li>ステータスを更新：報告済 → 確認中 → 対応中 → 解決 → クローズ</li>
              <li>解決時は「解決内容」を記入</li>
              <li>「保存」をクリック</li>
            </ol>
          </.section>

          <.section id="reports" title="8. レポート・分析">
            <h4>8.1 決算報告書</h4>
            <ol>
              <li>祭り詳細から「レポート」をクリック</li>
              <li>決算サマリーが表示されます：
                <ul>
                  <li>総予算</li>
                  <li>総支出</li>
                  <li>総収入</li>
                  <li>収支バランス</li>
                  <li>カテゴリ別支出</li>
                </ul>
              </li>
            </ol>

            <h4>8.2 年度比較</h4>
            <ol>
              <li>レポート画面で「年度比較」タブをクリック</li>
              <li>比較する祭りを選択</li>
              <li>以下の比較データが表示されます：
                <ul>
                  <li>支出の増減</li>
                  <li>収入の増減</li>
                  <li>カテゴリ別変化率</li>
                </ul>
              </li>
            </ol>

            <h4>8.3 PDF出力</h4>
            <ol>
              <li>レポート画面で「PDF出力」ボタンをクリック</li>
              <li>プレビューを確認</li>
              <li>「ダウンロード」をクリック</li>
            </ol>
          </.section>

          <.section id="other-features" title="9. その他の機能">
            <h4>9.1 チャット</h4>
            <ol>
              <li>祭り詳細から「チャット」をクリック</li>
              <li>チャットルーム一覧が表示されます</li>
              <li>ルームを選択してメッセージを送信</li>
            </ol>
            <p><strong>ルームタイプ:</strong></p>
            <ul>
              <li>一般: 全体連絡用</li>
              <li>緊急: 緊急連絡用</li>
              <li>スタッフ: スタッフ間連絡</li>
              <li>出店者: 出店者連絡</li>
            </ul>

            <h4>9.2 お知らせ</h4>
            <ol>
              <li>祭り詳細から「お知らせ」をクリック</li>
              <li>「新規作成」でお知らせを作成</li>
              <li>優先度（緊急/高/通常）を設定</li>
              <li>有効期限を設定</li>
            </ol>

            <h4>9.3 ドキュメント</h4>
            <ol>
              <li>祭り詳細から「ドキュメント」をクリック</li>
              <li>「アップロード」でファイルを追加</li>
              <li>カテゴリ（マニュアル/予算/計画/報告書/契約書）を設定</li>
            </ol>

            <h4>9.4 位置情報</h4>
            <ol>
              <li>祭り詳細から「位置情報」をクリック</li>
              <li>スタッフの現在位置がマップに表示されます</li>
              <li>「現在位置を共有」で自分の位置を共有</li>
            </ol>
          </.section>

          <.section id="troubleshooting" title="トラブルシューティング">
            <h4>よくある問題</h4>
            <div class="overflow-x-auto">
              <table class="table">
                <thead>
                  <tr>
                    <th>問題</th>
                    <th>解決方法</th>
                  </tr>
                </thead>
                <tbody>
                  <tr><td>経費が承認できない</td><td>承認権限を持つロールか確認</td></tr>
                  <tr><td>タスクが表示されない</td><td>カテゴリフィルターを確認</td></tr>
                  <tr><td>シフトが保存されない</td><td>必須項目の入力を確認</td></tr>
                  <tr><td>インシデントが更新されない</td><td>ページを再読み込み</td></tr>
                </tbody>
              </table>
            </div>

            <h4>サポート</h4>
            <p>問題が解決しない場合は、システム管理者に連絡してください。</p>
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
