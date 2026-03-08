defmodule MatsuriOps.LoggerTest do
  @moduledoc """
  ロギングモジュールのテスト。
  """

  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  alias MatsuriOps.Logger, as: AppLogger

  describe "log_user_action/3" do
    test "logs user action without error" do
      # ログレベルに関係なく、関数が正常に実行されることを確認
      assert :ok == AppLogger.log_user_action(123, "login", %{ip: "192.168.1.1"})
    end
  end

  describe "log_festival_action/3" do
    test "logs festival action without error" do
      assert :ok == AppLogger.log_festival_action(456, "created", %{name: "夏祭り"})
    end
  end

  describe "log_api_call/4" do
    test "logs API calls without error" do
      assert :ok == AppLogger.log_api_call("GET", "/api/festivals", 200, 50)
      assert :ok == AppLogger.log_api_call("POST", "/api/tasks", 500, 100)
    end
  end

  describe "log_performance/3" do
    test "logs performance metrics without error" do
      assert :ok == AppLogger.log_performance("database_query", 150, %{table: "festivals"})
      assert :ok == AppLogger.log_performance("slow_operation", 1500)
    end
  end

  describe "log_security_event/3" do
    test "logs security events as warning" do
      log =
        capture_log([level: :warning], fn ->
          AppLogger.log_security_event("failed_login", 123, %{attempts: 3})
        end)

      assert log =~ "Security event: failed_login"
    end
  end

  describe "log_job/3" do
    test "logs jobs without error" do
      assert :ok == AppLogger.log_job("cleanup", :completed, %{deleted_count: 10})
    end

    test "logs failed job as error" do
      log =
        capture_log([level: :error], fn ->
          AppLogger.log_job("sync", :failed, %{reason: "timeout"})
        end)

      assert log =~ "Job sync: failed"
    end
  end

  describe "log_pubsub_event/3" do
    test "logs pubsub events without error" do
      assert :ok == AppLogger.log_pubsub_event("festival:123", :updated, %{field: "name"})
    end
  end
end
