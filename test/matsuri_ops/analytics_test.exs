defmodule MatsuriOps.AnalyticsTest do
  @moduledoc """
  予測分析機能のテスト。

  TDDフェーズ: 🔴 RED → 🟢 GREEN
  """

  use MatsuriOps.DataCase

  alias MatsuriOps.Analytics

  describe "attendance_prediction/1" do
    test "predicts attendance based on historical data" do
      historical_data = [
        %{year: 2023, attendance: 1000},
        %{year: 2024, attendance: 1200},
        %{year: 2025, attendance: 1350}
      ]

      prediction = Analytics.predict_attendance(historical_data)

      assert prediction.predicted_value > 1350
      assert prediction.confidence > 0 and prediction.confidence <= 1
      assert prediction.trend in [:increasing, :decreasing, :stable]
    end

    test "handles empty historical data" do
      prediction = Analytics.predict_attendance([])

      assert prediction.predicted_value == nil
      assert prediction.confidence == 0
      assert prediction.error == :insufficient_data
    end

    test "calculates growth rate" do
      historical_data = [
        %{year: 2024, attendance: 1000},
        %{year: 2025, attendance: 1100}
      ]

      prediction = Analytics.predict_attendance(historical_data)

      assert prediction.growth_rate == 10.0
    end
  end

  describe "budget_forecast/1" do
    test "forecasts budget based on historical expenses" do
      historical_data = [
        %{year: 2023, total_expenses: 500_000, total_income: 600_000},
        %{year: 2024, total_expenses: 550_000, total_income: 650_000},
        %{year: 2025, total_expenses: 600_000, total_income: 700_000}
      ]

      forecast = Analytics.forecast_budget(historical_data)

      assert forecast.predicted_expenses > 600_000
      assert forecast.predicted_income > 700_000
      assert forecast.predicted_profit > 0
      assert forecast.confidence > 0
    end

    test "identifies expense trends by category" do
      historical_data = [
        %{year: 2024, categories: [
          %{name: "設営費", amount: 100_000},
          %{name: "人件費", amount: 200_000}
        ]},
        %{year: 2025, categories: [
          %{name: "設営費", amount: 120_000},
          %{name: "人件費", amount: 220_000}
        ]}
      ]

      forecast = Analytics.forecast_budget_by_category(historical_data)

      assert length(forecast.categories) == 2
      assert Enum.find(forecast.categories, &(&1.name == "設営費")).predicted_amount > 120_000
    end
  end

  describe "trend_analysis/1" do
    test "identifies increasing trend" do
      data_points = [100, 120, 140, 160, 180]

      analysis = Analytics.analyze_trend(data_points)

      assert analysis.trend == :increasing
      assert analysis.slope > 0
    end

    test "identifies decreasing trend" do
      data_points = [180, 160, 140, 120, 100]

      analysis = Analytics.analyze_trend(data_points)

      assert analysis.trend == :decreasing
      assert analysis.slope < 0
    end

    test "identifies stable trend" do
      data_points = [100, 102, 98, 101, 99]

      analysis = Analytics.analyze_trend(data_points)

      assert analysis.trend == :stable
      assert abs(analysis.slope) < 5
    end
  end

  describe "anomaly_detection/2" do
    test "detects anomalies in data" do
      normal_data = [100, 105, 98, 102, 95, 500, 103, 97]

      anomalies = Analytics.detect_anomalies(normal_data)

      assert length(anomalies) == 1
      assert hd(anomalies).value == 500
      assert hd(anomalies).index == 5
    end

    test "returns empty list for normal data" do
      normal_data = [100, 105, 98, 102, 95, 103, 97]

      anomalies = Analytics.detect_anomalies(normal_data)

      assert anomalies == []
    end
  end

  describe "seasonal_analysis/1" do
    test "identifies seasonal patterns" do
      # 月ごとの来場者データ（夏祭りを想定）
      monthly_data = [
        %{month: 1, value: 100},
        %{month: 2, value: 120},
        %{month: 3, value: 150},
        %{month: 4, value: 200},
        %{month: 5, value: 300},
        %{month: 6, value: 400},
        %{month: 7, value: 800},  # 夏祭りシーズン
        %{month: 8, value: 900},  # 夏祭りシーズン
        %{month: 9, value: 500},
        %{month: 10, value: 300},
        %{month: 11, value: 200},
        %{month: 12, value: 150}
      ]

      analysis = Analytics.analyze_seasonality(monthly_data)

      assert analysis.peak_months == [7, 8]
      assert analysis.low_months == [1, 2]
      assert analysis.seasonality_index != nil
    end
  end

  describe "comparative_analysis/2" do
    test "compares two festivals" do
      festival_a = %{
        attendance: 1000,
        budget: 500_000,
        satisfaction_score: 4.2,
        incident_count: 3
      }

      festival_b = %{
        attendance: 1200,
        budget: 600_000,
        satisfaction_score: 4.5,
        incident_count: 2
      }

      comparison = Analytics.compare_festivals(festival_a, festival_b)

      assert comparison.attendance_diff == 200
      assert comparison.budget_diff == 100_000
      assert comparison.satisfaction_diff == 0.3
      assert comparison.better_performance == :festival_b
    end
  end

  describe "prediction_accuracy/2" do
    test "calculates prediction accuracy" do
      predictions = [100, 120, 140]
      actuals = [105, 115, 145]

      accuracy = Analytics.calculate_accuracy(predictions, actuals)

      assert accuracy.mae > 0  # Mean Absolute Error
      assert accuracy.mape > 0  # Mean Absolute Percentage Error
      assert accuracy.accuracy_percent > 0 and accuracy.accuracy_percent <= 100
    end
  end

  describe "recommendations/1" do
    test "generates recommendations based on analysis" do
      analysis_data = %{
        attendance_trend: :decreasing,
        budget_status: :over_budget,
        satisfaction_score: 3.2,
        incident_rate: :high
      }

      recommendations = Analytics.generate_recommendations(analysis_data)

      assert length(recommendations) > 0
      assert Enum.all?(recommendations, &is_binary(&1.message))
      assert Enum.all?(recommendations, &(&1.priority in [:high, :medium, :low]))
    end
  end
end
