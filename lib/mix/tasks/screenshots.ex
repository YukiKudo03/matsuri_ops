defmodule Mix.Tasks.Screenshots do
  @moduledoc """
  ドキュメント用のスクリーンショットを自動取得するMixタスク。

  ## 使用方法

      # 全スクリーンショット取得
      MIX_ENV=test mix screenshots

      # 特定のスクリーンショットのみ
      MIX_ENV=test mix screenshots --only login,register

      # 出力ディレクトリ指定
      MIX_ENV=test mix screenshots --output docs/images

  ## 前提条件

  - ChromeDriver がインストールされていること
  - アプリケーションが起動可能な状態であること
  - MIX_ENV=test で実行すること

  ## 注意

  このタスクはtest環境でのみ実行可能です。
  代わりに test/support/screenshot_all.exs を使用することを推奨します:

      MIX_ENV=test mix run test/support/screenshot_all.exs
  """

  use Mix.Task

  @shortdoc "ドキュメント用スクリーンショットを取得（MIX_ENV=test必須）"

  @impl Mix.Task
  def run(_args) do
    Mix.shell().info("""
    ========================================
    スクリーンショット取得

    このタスクは test/support/screenshot_all.exs に
    移行しました。以下のコマンドで実行してください:

        MIX_ENV=test mix run test/support/screenshot_all.exs

    ========================================
    """)
  end
end
