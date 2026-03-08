defmodule MatsuriOps.Logger do
  @moduledoc """
  構造化ロギングモジュール。

  アプリケーション全体で一貫したログ出力を提供する。
  """

  require Logger

  @doc """
  ユーザーアクションをログに記録する。
  """
  def log_user_action(user_id, action, details \\ %{}) do
    metadata = build_metadata(:user_action, user_id, details)
    Logger.info("User action: #{action}", metadata)
  end

  @doc """
  祭りに関連するアクションをログに記録する。
  """
  def log_festival_action(festival_id, action, details \\ %{}) do
    metadata = build_metadata(:festival_action, nil, Map.put(details, :festival_id, festival_id))
    Logger.info("Festival action: #{action}", metadata)
  end

  @doc """
  API呼び出しをログに記録する。
  """
  def log_api_call(method, path, status, duration_ms) do
    metadata = %{
      type: :api_call,
      method: method,
      path: path,
      status: status,
      duration_ms: duration_ms
    }

    level = if status >= 400, do: :warning, else: :info
    Logger.log(level, "API #{method} #{path} -> #{status} (#{duration_ms}ms)", metadata)
  end

  @doc """
  PubSubイベントをログに記録する。
  """
  def log_pubsub_event(topic, event, details \\ %{}) do
    metadata = %{
      type: :pubsub_event,
      topic: topic,
      event: event,
      details: details
    }

    Logger.debug("PubSub event: #{topic} - #{event}", metadata)
  end

  @doc """
  パフォーマンスメトリクスをログに記録する。
  """
  def log_performance(operation, duration_ms, details \\ %{}) do
    metadata = %{
      type: :performance,
      operation: operation,
      duration_ms: duration_ms,
      details: details
    }

    level = if duration_ms > 1000, do: :warning, else: :debug
    Logger.log(level, "Performance: #{operation} took #{duration_ms}ms", metadata)
  end

  @doc """
  セキュリティイベントをログに記録する。
  """
  def log_security_event(event_type, user_id, details \\ %{}) do
    metadata = %{
      type: :security,
      event_type: event_type,
      user_id: user_id,
      details: details,
      timestamp: DateTime.utc_now()
    }

    Logger.warning("Security event: #{event_type}", metadata)
  end

  @doc """
  バックグラウンドジョブをログに記録する。
  """
  def log_job(job_name, status, details \\ %{}) do
    metadata = %{
      type: :job,
      job_name: job_name,
      status: status,
      details: details
    }

    level = if status == :failed, do: :error, else: :info
    Logger.log(level, "Job #{job_name}: #{status}", metadata)
  end

  @doc """
  処理時間を計測してログに記録する。
  """
  defmacro with_timing(operation, do: block) do
    quote do
      start_time = System.monotonic_time(:millisecond)

      result = unquote(block)

      duration = System.monotonic_time(:millisecond) - start_time
      MatsuriOps.Logger.log_performance(unquote(operation), duration)

      result
    end
  end

  # Private functions

  defp build_metadata(type, user_id, details) do
    base = %{
      type: type,
      timestamp: DateTime.utc_now()
    }

    base
    |> maybe_add_user_id(user_id)
    |> Map.merge(details)
  end

  defp maybe_add_user_id(metadata, nil), do: metadata
  defp maybe_add_user_id(metadata, user_id), do: Map.put(metadata, :user_id, user_id)
end
