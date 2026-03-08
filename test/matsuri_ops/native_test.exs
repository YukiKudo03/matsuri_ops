defmodule MatsuriOps.NativeTest do
  @moduledoc """
  ネイティブアプリ対応のテスト。

  TDDフェーズ: 🔴 RED → 🟢 GREEN
  """

  use MatsuriOps.DataCase

  alias MatsuriOps.Native

  describe "platform_detection/1" do
    test "detects iOS platform" do
      user_agent = "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X)"
      assert Native.detect_platform(user_agent) == :ios
    end

    test "detects Android platform" do
      user_agent = "Mozilla/5.0 (Linux; Android 13; Pixel 7)"
      assert Native.detect_platform(user_agent) == :android
    end

    test "detects web platform" do
      user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"
      assert Native.detect_platform(user_agent) == :web
    end

    test "returns web for unknown user agent" do
      assert Native.detect_platform(nil) == :web
      assert Native.detect_platform("") == :web
    end
  end

  describe "native_capabilities/1" do
    test "returns iOS capabilities" do
      capabilities = Native.capabilities(:ios)

      assert capabilities.push_notifications == true
      assert capabilities.camera_access == true
      assert capabilities.location_services == true
      assert capabilities.offline_storage == true
      assert capabilities.haptic_feedback == true
    end

    test "returns Android capabilities" do
      capabilities = Native.capabilities(:android)

      assert capabilities.push_notifications == true
      assert capabilities.camera_access == true
      assert capabilities.location_services == true
      assert capabilities.offline_storage == true
      assert capabilities.haptic_feedback == true
    end

    test "returns web capabilities" do
      capabilities = Native.capabilities(:web)

      assert capabilities.push_notifications == true
      assert capabilities.camera_access == true
      assert capabilities.location_services == true
      assert capabilities.offline_storage == true
      assert capabilities.haptic_feedback == false
    end
  end

  describe "app_config/1" do
    test "returns iOS app configuration" do
      config = Native.app_config(:ios)

      assert config.bundle_id == "com.matsuriops.app"
      assert config.min_version == "16.0"
      assert config.store_url =~ "apps.apple.com"
    end

    test "returns Android app configuration" do
      config = Native.app_config(:android)

      assert config.package_name == "com.matsuriops.app"
      assert config.min_sdk == 26
      assert config.store_url =~ "play.google.com"
    end

    test "returns nil for web" do
      assert Native.app_config(:web) == nil
    end
  end

  describe "deep_link/2" do
    test "generates festival deep link" do
      link = Native.deep_link(:festival, %{id: 123})
      assert link == "matsuriops://festival/123"
    end

    test "generates task deep link" do
      link = Native.deep_link(:task, %{festival_id: 1, id: 456})
      assert link == "matsuriops://festival/1/task/456"
    end

    test "generates dashboard deep link" do
      link = Native.deep_link(:dashboard, %{festival_id: 1})
      assert link == "matsuriops://festival/1/dashboard"
    end
  end

  describe "universal_link/2" do
    test "generates festival universal link" do
      link = Native.universal_link(:festival, %{id: 123})
      assert link == "https://matsuriops.app/festivals/123"
    end

    test "generates task universal link" do
      link = Native.universal_link(:task, %{festival_id: 1, id: 456})
      assert link == "https://matsuriops.app/festivals/1/tasks/456"
    end
  end
end
