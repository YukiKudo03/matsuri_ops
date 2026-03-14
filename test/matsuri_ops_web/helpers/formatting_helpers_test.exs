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

    test "formats zero" do
      assert FormattingHelpers.format_currency(0) == "0円"
    end

    test "formats small integer" do
      assert FormattingHelpers.format_currency(5) == "5円"
    end

    test "formats Decimal with decimals" do
      assert FormattingHelpers.format_currency(Decimal.new("1234.56")) == "1,235円"
    end
  end

  describe "add_thousand_separator/1" do
    test "adds separators to large numbers" do
      assert FormattingHelpers.add_thousand_separator("1234567") == "1,234,567"
    end

    test "handles small numbers" do
      assert FormattingHelpers.add_thousand_separator("123") == "123"
    end

    test "handles four-digit numbers" do
      assert FormattingHelpers.add_thousand_separator("1234") == "1,234"
    end

    test "handles single digit" do
      assert FormattingHelpers.add_thousand_separator("5") == "5"
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

    test "formats NaiveDateTime" do
      naive = ~N[2026-03-08 10:30:00]
      assert FormattingHelpers.format_date(naive) == "2026年03月08日"
    end
  end

  describe "format_datetime/1" do
    test "formats nil as dash" do
      assert FormattingHelpers.format_datetime(nil) == "-"
    end

    test "formats DateTime" do
      datetime = ~U[2026-03-08 10:30:00Z]
      assert FormattingHelpers.format_datetime(datetime) == "2026年03月08日 10:30"
    end

    test "formats NaiveDateTime" do
      naive = ~N[2026-03-08 14:45:00]
      assert FormattingHelpers.format_datetime(naive) == "2026年03月08日 14:45"
    end
  end

  describe "format_time/1" do
    test "formats nil as dash" do
      assert FormattingHelpers.format_time(nil) == "-"
    end

    test "formats Time" do
      assert FormattingHelpers.format_time(~T[14:30:00]) == "14:30"
    end

    test "formats DateTime" do
      datetime = ~U[2026-03-08 10:30:00Z]
      assert FormattingHelpers.format_time(datetime) == "10:30"
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

    test "formats large megabytes" do
      assert FormattingHelpers.format_file_size(5 * 1024 * 1024) == "5.0 MB"
    end
  end

  describe "calculate_percentage/2" do
    test "returns 0.0 for nil total" do
      assert FormattingHelpers.calculate_percentage(50, nil) == 0.0
    end

    test "returns 0.0 for zero total" do
      assert FormattingHelpers.calculate_percentage(50, 0) == 0.0
    end

    test "calculates correct percentage" do
      result = FormattingHelpers.calculate_percentage(Decimal.new(25), Decimal.new(100))
      assert result == 25.0
    end

    test "calculates with rounding" do
      result = FormattingHelpers.calculate_percentage(Decimal.new(1), Decimal.new(3))
      assert result == 33.3
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

  describe "priority_label/1" do
    test "returns Japanese labels for all priorities" do
      assert FormattingHelpers.priority_label("high") == "高"
      assert FormattingHelpers.priority_label("normal") == "通常"
      assert FormattingHelpers.priority_label("low") == "低"
    end

    test "returns original for unknown priority" do
      assert FormattingHelpers.priority_label("custom") == "custom"
    end
  end

  describe "document_category_label/1" do
    test "returns Japanese labels for all categories" do
      assert FormattingHelpers.document_category_label("manual") == "マニュアル"
      assert FormattingHelpers.document_category_label("template") == "テンプレート"
      assert FormattingHelpers.document_category_label("report") == "報告書"
      assert FormattingHelpers.document_category_label("contract") == "契約書"
      assert FormattingHelpers.document_category_label("other") == "その他"
    end

    test "returns original for unknown category" do
      assert FormattingHelpers.document_category_label("custom") == "custom"
    end
  end

  describe "status_color/1" do
    test "returns appropriate color classes" do
      assert FormattingHelpers.status_color("pending") =~ "yellow"
      assert FormattingHelpers.status_color("in_progress") =~ "blue"
      assert FormattingHelpers.status_color("completed") =~ "green"
      assert FormattingHelpers.status_color("failed") =~ "red"
      assert FormattingHelpers.status_color("cancelled") =~ "gray"
    end

    test "returns default for unknown status" do
      assert FormattingHelpers.status_color("unknown") =~ "gray"
    end
  end
end
