defmodule MatsuriOps.Error do
  @moduledoc """
  エラーハンドリングモジュール。

  アプリケーション全体で一貫したエラー処理を提供する。
  """

  require Logger

  @type error_type :: :not_found | :unauthorized | :forbidden | :validation | :internal | :external

  @doc """
  エラーをログに記録し、ユーザーフレンドリーなメッセージを返す。
  """
  def handle_error(error, context \\ %{})

  def handle_error(%Ecto.NoResultsError{} = error, context) do
    log_error(:not_found, error, context)
    {:error, :not_found, "指定されたリソースが見つかりません"}
  end

  def handle_error(%Ecto.Changeset{} = changeset, context) do
    errors = format_changeset_errors(changeset)
    log_error(:validation, errors, context)
    {:error, :validation, errors}
  end

  def handle_error({:error, %Ecto.Changeset{} = changeset}, context) do
    handle_error(changeset, context)
  end

  def handle_error({:error, reason}, context) when is_atom(reason) do
    log_error(reason, reason, context)
    {:error, reason, translate_error_reason(reason)}
  end

  def handle_error({:error, reason}, context) when is_binary(reason) do
    log_error(:internal, reason, context)
    {:error, :internal, reason}
  end

  def handle_error(error, context) do
    log_error(:internal, error, context)
    {:error, :internal, "予期しないエラーが発生しました"}
  end

  @doc """
  Ecto Changesetのエラーを人間が読める形式にフォーマットする。
  """
  def format_changeset_errors(%Ecto.Changeset{} = changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end

  @doc """
  エラーを安全にラップする。
  """
  def wrap_error(fun, context \\ %{}) when is_function(fun, 0) do
    try do
      case fun.() do
        {:ok, result} -> {:ok, result}
        {:error, _} = error -> handle_error(error, context)
        result -> {:ok, result}
      end
    rescue
      error -> handle_error(error, context)
    catch
      :exit, reason -> handle_error({:error, reason}, context)
    end
  end

  # Private functions

  defp log_error(type, error, context) do
    metadata = Map.merge(context, %{error_type: type, error: inspect(error)})

    case type do
      :not_found ->
        Logger.info("Resource not found", metadata)

      :validation ->
        Logger.info("Validation error", metadata)

      :unauthorized ->
        Logger.warning("Unauthorized access attempt", metadata)

      :forbidden ->
        Logger.warning("Forbidden access attempt", metadata)

      _ ->
        Logger.error("Error occurred", metadata)
    end
  end

  defp translate_error_reason(:not_found), do: "リソースが見つかりません"
  defp translate_error_reason(:unauthorized), do: "認証が必要です"
  defp translate_error_reason(:forbidden), do: "アクセス権限がありません"
  defp translate_error_reason(:conflict), do: "リソースが競合しています"
  defp translate_error_reason(:timeout), do: "リクエストがタイムアウトしました"
  defp translate_error_reason(:overlap), do: "スケジュールが重複しています"
  defp translate_error_reason(reason) when is_atom(reason), do: "エラーが発生しました: #{reason}"
end
