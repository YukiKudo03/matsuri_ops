defmodule MatsuriOps.Native do
  @moduledoc """
  ネイティブアプリ対応モジュール。

  LiveView Native統合の準備として、プラットフォーム検出、
  ネイティブ機能、ディープリンク生成などを提供する。
  """

  @doc """
  User-Agentからプラットフォームを検出する。
  """
  def detect_platform(nil), do: :web
  def detect_platform(""), do: :web

  def detect_platform(user_agent) when is_binary(user_agent) do
    cond do
      String.contains?(user_agent, "iPhone") or String.contains?(user_agent, "iPad") ->
        :ios

      String.contains?(user_agent, "Android") ->
        :android

      true ->
        :web
    end
  end

  @doc """
  プラットフォームごとの機能をリストする。
  """
  def capabilities(:ios) do
    %{
      push_notifications: true,
      camera_access: true,
      location_services: true,
      offline_storage: true,
      haptic_feedback: true,
      face_id: true,
      apple_pay: true
    }
  end

  def capabilities(:android) do
    %{
      push_notifications: true,
      camera_access: true,
      location_services: true,
      offline_storage: true,
      haptic_feedback: true,
      fingerprint: true,
      google_pay: true
    }
  end

  def capabilities(:web) do
    %{
      push_notifications: true,
      camera_access: true,
      location_services: true,
      offline_storage: true,
      haptic_feedback: false,
      web_share: true
    }
  end

  @doc """
  アプリストア設定を返す。
  """
  def app_config(:ios) do
    %{
      bundle_id: "com.matsuriops.app",
      min_version: "16.0",
      store_url: "https://apps.apple.com/app/matsuriops/id123456789",
      team_id: "XXXXXXXXXX"
    }
  end

  def app_config(:android) do
    %{
      package_name: "com.matsuriops.app",
      min_sdk: 26,
      target_sdk: 34,
      store_url: "https://play.google.com/store/apps/details?id=com.matsuriops.app"
    }
  end

  def app_config(:web), do: nil

  @doc """
  ディープリンクを生成する。
  """
  def deep_link(:festival, %{id: id}) do
    "matsuriops://festival/#{id}"
  end

  def deep_link(:task, %{festival_id: festival_id, id: id}) do
    "matsuriops://festival/#{festival_id}/task/#{id}"
  end

  def deep_link(:dashboard, %{festival_id: festival_id}) do
    "matsuriops://festival/#{festival_id}/dashboard"
  end

  def deep_link(:chat, %{festival_id: festival_id, room_id: room_id}) do
    "matsuriops://festival/#{festival_id}/chat/#{room_id}"
  end

  def deep_link(:notification, %{id: id}) do
    "matsuriops://notification/#{id}"
  end

  @doc """
  ユニバーサルリンク（iOS）/ App Links（Android）を生成する。
  """
  def universal_link(:festival, %{id: id}) do
    "https://matsuriops.app/festivals/#{id}"
  end

  def universal_link(:task, %{festival_id: festival_id, id: id}) do
    "https://matsuriops.app/festivals/#{festival_id}/tasks/#{id}"
  end

  def universal_link(:dashboard, %{festival_id: festival_id}) do
    "https://matsuriops.app/festivals/#{festival_id}/dashboard"
  end

  @doc """
  アプリバナー用のメタデータを生成する。
  """
  def smart_app_banner_meta do
    %{
      "apple-itunes-app" => "app-id=123456789",
      "google-play-app" => "app-id=com.matsuriops.app"
    }
  end

  @doc """
  プラットフォーム固有のスタイル調整を返す。
  """
  def platform_styles(:ios) do
    %{
      safe_area_inset: true,
      status_bar_style: "dark-content",
      navigation_bar_hidden: false
    }
  end

  def platform_styles(:android) do
    %{
      status_bar_color: "#f97316",
      navigation_bar_color: "#ffffff",
      edge_to_edge: true
    }
  end

  def platform_styles(:web), do: %{}
end
