defmodule MatsuriOpsWeb.FormattingHelpers do
  @moduledoc """
  共通フォーマットヘルパー関数。

  複数のLiveViewやコンポーネントで使用される
  フォーマット関数を集約する。
  """

  @doc """
  金額を日本円形式でフォーマットする。
  """
  def format_currency(nil), do: "-"
  def format_currency(%Decimal{} = amount) do
    amount
    |> Decimal.round(0)
    |> Decimal.to_integer()
    |> format_currency()
  end
  def format_currency(amount) when is_integer(amount) do
    amount
    |> Integer.to_string()
    |> add_thousand_separator()
    |> Kernel.<>("円")
  end
  def format_currency(amount) when is_float(amount) do
    amount
    |> round()
    |> trunc()
    |> format_currency()
  end

  @doc """
  3桁区切りのカンマを追加する。
  """
  def add_thousand_separator(number_string) when is_binary(number_string) do
    number_string
    |> String.reverse()
    |> String.replace(~r/(\d{3})(?=\d)/, "\\1,")
    |> String.reverse()
  end

  @doc """
  変化率をフォーマットする。
  """
  def format_rate(nil), do: "-"
  def format_rate(rate) when is_float(rate) do
    sign = if rate >= 0, do: "+", else: ""
    "#{sign}#{Float.round(rate, 1)}%"
  end

  @doc """
  日付を日本語形式でフォーマットする。
  """
  def format_date(nil), do: "-"
  def format_date(%Date{} = date) do
    Calendar.strftime(date, "%Y年%m月%d日")
  end
  def format_date(%DateTime{} = datetime) do
    datetime
    |> DateTime.to_date()
    |> format_date()
  end
  def format_date(%NaiveDateTime{} = naive) do
    naive
    |> NaiveDateTime.to_date()
    |> format_date()
  end

  @doc """
  日時を日本語形式でフォーマットする。
  """
  def format_datetime(nil), do: "-"
  def format_datetime(%DateTime{} = datetime) do
    Calendar.strftime(datetime, "%Y年%m月%d日 %H:%M")
  end
  def format_datetime(%NaiveDateTime{} = naive) do
    Calendar.strftime(naive, "%Y年%m月%d日 %H:%M")
  end

  @doc """
  時刻を日本語形式でフォーマットする。
  """
  def format_time(nil), do: "-"
  def format_time(%Time{} = time) do
    Calendar.strftime(time, "%H:%M")
  end
  def format_time(%DateTime{} = datetime) do
    Calendar.strftime(datetime, "%H:%M")
  end

  @doc """
  ファイルサイズを人間が読める形式でフォーマットする。
  """
  def format_file_size(nil), do: "-"
  def format_file_size(bytes) when is_integer(bytes) and bytes < 1024 do
    "#{bytes} B"
  end
  def format_file_size(bytes) when is_integer(bytes) and bytes < 1024 * 1024 do
    kb = Float.round(bytes / 1024, 1)
    "#{kb} KB"
  end
  def format_file_size(bytes) when is_integer(bytes) do
    mb = Float.round(bytes / (1024 * 1024), 2)
    "#{mb} MB"
  end

  @doc """
  パーセンテージを計算してフォーマットする。
  """
  def calculate_percentage(_value, nil), do: 0.0
  def calculate_percentage(_value, total) when total == 0, do: 0.0
  def calculate_percentage(value, total) do
    value
    |> Decimal.div(total)
    |> Decimal.mult(Decimal.new(100))
    |> Decimal.round(1)
    |> Decimal.to_float()
  end

  @doc """
  チャットルームタイプを日本語ラベルに変換する。
  """
  def room_type_label("general"), do: "一般"
  def room_type_label("emergency"), do: "緊急"
  def room_type_label("staff"), do: "スタッフ"
  def room_type_label("vendor"), do: "出店者"
  def room_type_label(type), do: type

  @doc """
  優先度を日本語ラベルに変換する。
  """
  def priority_label("high"), do: "高"
  def priority_label("normal"), do: "通常"
  def priority_label("low"), do: "低"
  def priority_label(priority), do: priority

  @doc """
  ドキュメントカテゴリを日本語ラベルに変換する。
  """
  def document_category_label("manual"), do: "マニュアル"
  def document_category_label("template"), do: "テンプレート"
  def document_category_label("report"), do: "報告書"
  def document_category_label("contract"), do: "契約書"
  def document_category_label("other"), do: "その他"
  def document_category_label(category), do: category

  @doc """
  ステータスカラークラスを返す。
  """
  def status_color("pending"), do: "bg-yellow-100 text-yellow-800"
  def status_color("in_progress"), do: "bg-blue-100 text-blue-800"
  def status_color("completed"), do: "bg-green-100 text-green-800"
  def status_color("cancelled"), do: "bg-gray-100 text-gray-800"
  def status_color("failed"), do: "bg-red-100 text-red-800"
  def status_color(_), do: "bg-gray-100 text-gray-800"
end
