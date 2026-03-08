defmodule MatsuriOpsWeb.FormattingHelpersTest do
  @moduledoc """
  共通フォーマットヘルパーのテスト。
  """

  use ExUnit.Case, async: true

  alias MatsuriOpsWeb.FormattingHelpers

  describe "format_currency/1" do
    test "formats nil as dash" do
      assert FormattingHelpers.format_currency(nil) == "-"
    end

    test "formats integer amount" do
      assert FormattingHelpers.format_currency(1000) == "1,000円"
      assert FormattingHelpers.format_currency(1234567) == "1,234,567円"
    end

    test "formats Decimal amount" do
      assert FormattingHelpers.format_currency(Decimal.new("1500")) == "1,500円"
    end

    test "formats float amount" do
      assert FormattingHelpers.format_currency(1500.5) == "1,501円"
    end
  end

  describe "add_thousand_separator/1" do
    test "adds separators to large numbers" do
      assert FormattingHelpers.add_thousand_separator("1234567") == "1,234,567"
    end

    test "handles small numbers" do
      assert FormattingHelpers.add_thousand_separator("123") == "123"
    end
  end

  describe "format_rate/1" do
    test "formats nil as dash" do
      assert FormattingHelpers.format_rate(nil) == "-"
    end

    test "formats positive rate with plus sign" do
      assert FormattingHelpers.format_rate(10.5) == "+10.5%"
    end

    test "formats negative rate" do
      assert FormattingHelpers.format_rate(-5.5) == "-5.5%"
    end

    test "formats zero" do
      assert FormattingHelpers.format_rate(0.0) == "+0.0%"
    end
  end

  describe "format_date/1" do
    test "formats nil as dash" do
      assert FormattingHelpers.format_date(nil) == "-"
    end

    test "formats Date" do
      assert FormattingHelpers.format_date(~D[2026-03-08]) == "2026年03月08日"
    end

    test "formats DateTime" do
      datetime = ~U[2026-03-08 10:30:00Z]
      assert FormattingHelpers.format_date(datetime) == "2026年03月08日"
    end
  end

  describe "format_file_size/1" do
    test "formats nil as dash" do
      assert FormattingHelpers.format_file_size(nil) == "-"
    end

    test "formats bytes" do
      assert FormattingHelpers.format_file_size(500) == "500 B"
    end

    test "formats kilobytes" do
      assert FormattingHelpers.format_file_size(1024) == "1.0 KB"
    end

    test "formats megabytes" do
      assert FormattingHelpers.format_file_size(1024 * 1024) == "1.0 MB"
    end
  end

  describe "room_type_label/1" do
    test "returns Japanese label for known types" do
      assert FormattingHelpers.room_type_label("general") == "一般"
      assert FormattingHelpers.room_type_label("emergency") == "緊急"
      assert FormattingHelpers.room_type_label("staff") == "スタッフ"
      assert FormattingHelpers.room_type_label("vendor") == "出店者"
    end

    test "returns original for unknown types" do
      assert FormattingHelpers.room_type_label("custom") == "custom"
    end
  end

  describe "status_color/1" do
    test "returns appropriate color classes" do
      assert FormattingHelpers.status_color("pending") =~ "yellow"
      assert FormattingHelpers.status_color("in_progress") =~ "blue"
      assert FormattingHelpers.status_color("completed") =~ "green"
      assert FormattingHelpers.status_color("failed") =~ "red"
    end
  end
end
