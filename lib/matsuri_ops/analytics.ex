defmodule MatsuriOps.Analytics do
  @moduledoc """
  予測分析モジュール。

  過去のデータに基づいて来場者数予測、予算予測、
  トレンド分析などの分析機能を提供する。
  """

  # =====================
  # Attendance Prediction
  # =====================

  @doc """
  過去の来場者データから将来の来場者数を予測する。
  """
  def predict_attendance([]), do: %{predicted_value: nil, confidence: 0, error: :insufficient_data}

  def predict_attendance(historical_data) when length(historical_data) < 2 do
    %{predicted_value: nil, confidence: 0, error: :insufficient_data}
  end

  def predict_attendance(historical_data) do
    sorted = Enum.sort_by(historical_data, & &1.year)
    values = Enum.map(sorted, & &1.attendance)

    trend = analyze_trend(values)
    growth_rate = calculate_growth_rate(values)
    last_value = List.last(values)

    predicted_value = round(last_value * (1 + growth_rate / 100))
    confidence = calculate_confidence(length(values), trend.r_squared)

    %{
      predicted_value: predicted_value,
      confidence: confidence,
      trend: trend.trend,
      growth_rate: Float.round(growth_rate, 1),
      historical_avg: Enum.sum(values) / length(values)
    }
  end

  defp calculate_growth_rate(values) when length(values) < 2, do: 0.0

  defp calculate_growth_rate(values) do
    first = hd(values)
    last = List.last(values)

    if first > 0 do
      (last - first) / first * 100 / (length(values) - 1)
    else
      0.0
    end
  end

  defp calculate_confidence(data_points, r_squared) do
    base_confidence = min(data_points / 10, 1.0)
    r_factor = r_squared || 0.5
    Float.round(base_confidence * r_factor, 2)
  end

  # =====================
  # Budget Forecast
  # =====================

  @doc """
  過去の予算データから将来の予算を予測する。
  """
  def forecast_budget([]), do: %{predicted_expenses: 0, predicted_income: 0, predicted_profit: 0, confidence: 0}

  def forecast_budget(historical_data) do
    sorted = Enum.sort_by(historical_data, & &1.year)

    expenses = Enum.map(sorted, & &1.total_expenses)
    incomes = Enum.map(sorted, & &1.total_income)

    expense_growth = calculate_growth_rate(expenses)
    income_growth = calculate_growth_rate(incomes)

    last_expense = List.last(expenses)
    last_income = List.last(incomes)

    predicted_expenses = round(last_expense * (1 + expense_growth / 100))
    predicted_income = round(last_income * (1 + income_growth / 100))

    %{
      predicted_expenses: predicted_expenses,
      predicted_income: predicted_income,
      predicted_profit: predicted_income - predicted_expenses,
      expense_growth_rate: Float.round(expense_growth, 1),
      income_growth_rate: Float.round(income_growth, 1),
      confidence: calculate_confidence(length(historical_data), 0.7)
    }
  end

  @doc """
  カテゴリ別の予算予測を行う。
  """
  def forecast_budget_by_category(historical_data) do
    categories =
      historical_data
      |> Enum.flat_map(& &1.categories)
      |> Enum.group_by(& &1.name)
      |> Enum.map(fn {name, cat_data} ->
        amounts = Enum.map(cat_data, & &1.amount)
        growth_rate = calculate_growth_rate(amounts)
        last_amount = List.last(amounts)
        predicted = round(last_amount * (1 + growth_rate / 100))

        %{
          name: name,
          predicted_amount: predicted,
          growth_rate: Float.round(growth_rate, 1)
        }
      end)

    %{categories: categories}
  end

  # =====================
  # Trend Analysis
  # =====================

  @doc """
  データポイントのトレンドを分析する。
  """
  def analyze_trend([]), do: %{trend: :unknown, slope: 0, r_squared: nil}

  def analyze_trend(data_points) when length(data_points) < 2 do
    %{trend: :unknown, slope: 0, r_squared: nil}
  end

  def analyze_trend(data_points) do
    n = length(data_points)
    x_values = Enum.to_list(1..n)
    y_values = data_points

    # 線形回帰の計算
    sum_x = Enum.sum(x_values)
    sum_y = Enum.sum(y_values)
    sum_xy = Enum.zip(x_values, y_values) |> Enum.map(fn {x, y} -> x * y end) |> Enum.sum()
    sum_x2 = Enum.map(x_values, &(&1 * &1)) |> Enum.sum()

    slope = (n * sum_xy - sum_x * sum_y) / (n * sum_x2 - sum_x * sum_x)

    # R²の計算
    mean_y = sum_y / n
    ss_tot = Enum.map(y_values, fn y -> :math.pow(y - mean_y, 2) end) |> Enum.sum()
    intercept = (sum_y - slope * sum_x) / n
    predicted = Enum.map(x_values, fn x -> intercept + slope * x end)
    ss_res = Enum.zip(y_values, predicted) |> Enum.map(fn {y, p} -> :math.pow(y - p, 2) end) |> Enum.sum()
    r_squared = if ss_tot > 0, do: 1 - ss_res / ss_tot, else: 0

    # トレンドの判定
    avg = Enum.sum(y_values) / n
    threshold = avg * 0.05  # 5%の閾値

    trend =
      cond do
        slope > threshold -> :increasing
        slope < -threshold -> :decreasing
        true -> :stable
      end

    %{
      trend: trend,
      slope: Float.round(slope, 2),
      r_squared: Float.round(r_squared, 3)
    }
  end

  # =====================
  # Anomaly Detection
  # =====================

  @doc """
  データ中の異常値を検出する。
  """
  def detect_anomalies([]), do: []

  def detect_anomalies(data) when length(data) < 3, do: []

  def detect_anomalies(data) do
    mean = Enum.sum(data) / length(data)
    std_dev = calculate_std_dev(data, mean)
    threshold = 2.5  # 標準偏差の2.5倍を閾値とする

    data
    |> Enum.with_index()
    |> Enum.filter(fn {value, _} ->
      abs(value - mean) > threshold * std_dev
    end)
    |> Enum.map(fn {value, index} ->
      %{
        value: value,
        index: index,
        deviation: Float.round(abs(value - mean) / std_dev, 2)
      }
    end)
  end

  defp calculate_std_dev(data, mean) do
    variance = Enum.map(data, fn x -> :math.pow(x - mean, 2) end) |> Enum.sum()
    :math.sqrt(variance / length(data))
  end

  # =====================
  # Seasonal Analysis
  # =====================

  @doc """
  季節性パターンを分析する。
  """
  def analyze_seasonality([]), do: %{peak_months: [], low_months: [], seasonality_index: nil}

  def analyze_seasonality(monthly_data) do
    sorted = Enum.sort_by(monthly_data, & &1.month)
    values = Enum.map(sorted, & &1.value)
    avg = Enum.sum(values) / length(values)

    # 季節性指数の計算
    seasonality_index =
      Enum.map(sorted, fn %{month: month, value: value} ->
        %{month: month, index: Float.round(value / avg, 2)}
      end)

    # ピーク月と低迷月の特定
    sorted_by_value = Enum.sort_by(seasonality_index, & &1.index, :desc)
    peak_months = sorted_by_value |> Enum.take(2) |> Enum.map(& &1.month)
    low_months = sorted_by_value |> Enum.reverse() |> Enum.take(2) |> Enum.map(& &1.month)

    %{
      peak_months: Enum.sort(peak_months),
      low_months: Enum.sort(low_months),
      seasonality_index: seasonality_index
    }
  end

  # =====================
  # Comparative Analysis
  # =====================

  @doc """
  2つの祭りを比較する。
  """
  def compare_festivals(festival_a, festival_b) do
    attendance_diff = festival_b.attendance - festival_a.attendance
    budget_diff = festival_b.budget - festival_a.budget
    satisfaction_diff = Float.round(festival_b.satisfaction_score - festival_a.satisfaction_score, 1)
    incident_diff = festival_b.incident_count - festival_a.incident_count

    # 総合スコアの計算（正規化された指標の加重平均）
    score_a = calculate_festival_score(festival_a)
    score_b = calculate_festival_score(festival_b)

    better_performance = if score_b > score_a, do: :festival_b, else: :festival_a

    %{
      attendance_diff: attendance_diff,
      budget_diff: budget_diff,
      satisfaction_diff: satisfaction_diff,
      incident_diff: incident_diff,
      better_performance: better_performance,
      score_a: Float.round(score_a, 2),
      score_b: Float.round(score_b, 2)
    }
  end

  defp calculate_festival_score(festival) do
    # 正規化スコアの計算（満足度を重視）
    satisfaction_weight = 0.4
    attendance_weight = 0.3
    incident_weight = 0.3

    satisfaction_score = festival.satisfaction_score / 5 * 100 * satisfaction_weight
    attendance_score = min(festival.attendance / 1000, 1) * 100 * attendance_weight
    incident_score = max(0, 100 - festival.incident_count * 20) * incident_weight

    satisfaction_score + attendance_score + incident_score
  end

  # =====================
  # Prediction Accuracy
  # =====================

  @doc """
  予測精度を計算する。
  """
  def calculate_accuracy([], _), do: %{mae: 0, mape: 0, accuracy_percent: 0}
  def calculate_accuracy(_, []), do: %{mae: 0, mape: 0, accuracy_percent: 0}

  def calculate_accuracy(predictions, actuals) do
    pairs = Enum.zip(predictions, actuals)
    n = length(pairs)

    # MAE (Mean Absolute Error)
    mae = Enum.map(pairs, fn {p, a} -> abs(p - a) end) |> Enum.sum() |> Kernel./(n)

    # MAPE (Mean Absolute Percentage Error)
    mape =
      Enum.map(pairs, fn {p, a} ->
        if a != 0, do: abs((a - p) / a) * 100, else: 0
      end)
      |> Enum.sum()
      |> Kernel./(n)

    accuracy_percent = max(0, 100 - mape)

    %{
      mae: Float.round(mae, 2),
      mape: Float.round(mape, 2),
      accuracy_percent: Float.round(accuracy_percent, 2)
    }
  end

  # =====================
  # Recommendations
  # =====================

  @doc """
  分析結果に基づいて改善提案を生成する。
  """
  def generate_recommendations(analysis_data) do
    recommendations = []

    recommendations =
      if analysis_data.attendance_trend == :decreasing do
        [%{
          message: "来場者数が減少傾向にあります。広報活動の強化や新しいイベント企画を検討してください。",
          priority: :high,
          category: :attendance
        } | recommendations]
      else
        recommendations
      end

    recommendations =
      if analysis_data.budget_status == :over_budget do
        [%{
          message: "予算超過の傾向があります。支出の見直しや追加収入源の検討をお勧めします。",
          priority: :high,
          category: :budget
        } | recommendations]
      else
        recommendations
      end

    recommendations =
      if analysis_data.satisfaction_score < 3.5 do
        [%{
          message: "満足度が低下しています。来場者アンケートを実施し、改善点を特定してください。",
          priority: :medium,
          category: :satisfaction
        } | recommendations]
      else
        recommendations
      end

    recommendations =
      if analysis_data.incident_rate == :high do
        [%{
          message: "インシデント発生率が高くなっています。安全対策の強化を検討してください。",
          priority: :high,
          category: :safety
        } | recommendations]
      else
        recommendations
      end

    if recommendations == [] do
      [%{
        message: "全体的に良好な状態です。現在の運営を継続してください。",
        priority: :low,
        category: :general
      }]
    else
      recommendations
    end
  end
end
