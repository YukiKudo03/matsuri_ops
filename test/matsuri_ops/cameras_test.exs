defmodule MatsuriOps.CamerasTest do
  @moduledoc """
  ライブカメラ連携のテスト。

  TDDフェーズ: 🔴 RED → 🟢 GREEN
  """

  use MatsuriOps.DataCase

  alias MatsuriOps.Cameras
  alias MatsuriOps.Cameras.Camera

  describe "cameras" do
    setup do
      user = user_fixture()
      festival = festival_fixture(user)
      {:ok, user: user, festival: festival}
    end

    @valid_attrs %{
      name: "メインステージカメラ",
      description: "メインステージ正面からの映像",
      stream_url: "https://stream.example.com/main",
      stream_type: "hls",
      location: "メインステージ",
      latitude: 35.6762,
      longitude: 139.6503,
      status: "online"
    }

    @invalid_attrs %{name: nil, stream_url: nil}

    test "list_cameras/1 returns all cameras for festival", %{festival: festival} do
      camera = camera_fixture(festival)
      cameras = Cameras.list_cameras(festival.id)
      assert length(cameras) == 1
      assert hd(cameras).id == camera.id
    end

    test "get_camera!/1 returns camera by id", %{festival: festival} do
      camera = camera_fixture(festival)
      assert Cameras.get_camera!(camera.id).id == camera.id
    end

    test "create_camera/2 with valid data creates camera", %{festival: festival} do
      assert {:ok, %Camera{} = camera} = Cameras.create_camera(festival, @valid_attrs)
      assert camera.name == "メインステージカメラ"
      assert camera.stream_type == "hls"
      assert camera.status == "online"
    end

    test "create_camera/2 with invalid data returns error", %{festival: festival} do
      assert {:error, %Ecto.Changeset{}} = Cameras.create_camera(festival, @invalid_attrs)
    end

    test "update_camera/2 with valid data updates camera", %{festival: festival} do
      camera = camera_fixture(festival)
      assert {:ok, %Camera{} = updated} = Cameras.update_camera(camera, %{name: "更新済みカメラ"})
      assert updated.name == "更新済みカメラ"
    end

    test "delete_camera/1 deletes camera", %{festival: festival} do
      camera = camera_fixture(festival)
      assert {:ok, %Camera{}} = Cameras.delete_camera(camera)
      assert_raise Ecto.NoResultsError, fn -> Cameras.get_camera!(camera.id) end
    end

    test "change_camera/1 returns changeset", %{festival: festival} do
      camera = camera_fixture(festival)
      assert %Ecto.Changeset{} = Cameras.change_camera(camera)
    end
  end

  describe "camera status" do
    setup do
      user = user_fixture()
      festival = festival_fixture(user)
      {:ok, festival: festival}
    end

    test "update_camera_status/2 updates status", %{festival: festival} do
      camera = camera_fixture(festival, %{status: "online"})
      assert {:ok, updated} = Cameras.update_camera_status(camera, "offline")
      assert updated.status == "offline"
    end

    test "list_online_cameras/1 returns only online cameras", %{festival: festival} do
      _online = camera_fixture(festival, %{name: "Online", status: "online"})
      _offline = camera_fixture(festival, %{name: "Offline", status: "offline"})

      online_cameras = Cameras.list_online_cameras(festival.id)
      assert length(online_cameras) == 1
      assert hd(online_cameras).name == "Online"
    end

    test "check_camera_health/1 returns health status", %{festival: festival} do
      camera = camera_fixture(festival)
      # モック環境ではデフォルトで正常を返す
      assert {:ok, health} = Cameras.check_camera_health(camera)
      assert health.status in [:healthy, :unknown]
    end
  end

  describe "stream types" do
    test "supported_stream_types/0 returns list of types" do
      types = Cameras.supported_stream_types()
      assert "hls" in types
      assert "rtsp" in types
      assert "webrtc" in types
    end

    test "stream_player_config/1 returns player configuration" do
      config = Cameras.stream_player_config("hls")
      assert config.player == "hls.js"
      assert config.autoplay == false
    end
  end

  describe "camera recording" do
    setup do
      user = user_fixture()
      festival = festival_fixture(user)
      camera = camera_fixture(festival)
      {:ok, camera: camera}
    end

    test "start_recording/1 starts recording session", %{camera: camera} do
      assert {:ok, recording} = Cameras.start_recording(camera)
      assert recording.camera_id == camera.id
      assert recording.status == "recording"
      assert recording.started_at != nil
    end

    test "stop_recording/1 stops recording session", %{camera: camera} do
      {:ok, recording} = Cameras.start_recording(camera)
      assert {:ok, stopped} = Cameras.stop_recording(recording)
      assert stopped.status == "completed"
      assert stopped.ended_at != nil
    end

    test "list_recordings/1 returns camera recordings", %{camera: camera} do
      {:ok, recording} = Cameras.start_recording(camera)
      Cameras.stop_recording(recording)

      recordings = Cameras.list_recordings(camera.id)
      assert length(recordings) == 1
    end
  end

  # Fixtures
  defp user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "test#{System.unique_integer()}@example.com",
        password: "valid_password123"
      })
      |> MatsuriOps.Accounts.register_user()

    user
  end

  defp festival_fixture(user, attrs \\ %{}) do
    {:ok, festival} =
      attrs
      |> Enum.into(%{
        name: "テスト祭り#{System.unique_integer()}",
        description: "テスト用祭り",
        start_date: Date.utc_today(),
        end_date: Date.add(Date.utc_today(), 1),
        location: "テスト会場",
        status: "planning"
      })
      |> then(&MatsuriOps.Festivals.create_festival(user, &1))

    festival
  end

  defp camera_fixture(festival, attrs \\ %{}) do
    {:ok, camera} =
      attrs
      |> Enum.into(%{
        name: "テストカメラ#{System.unique_integer()}",
        stream_url: "https://stream.example.com/test",
        stream_type: "hls",
        status: "online"
      })
      |> then(&Cameras.create_camera(festival, &1))

    camera
  end
end
