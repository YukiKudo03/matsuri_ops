defmodule MatsuriOps.Cameras.CameraTest do
  use MatsuriOps.DataCase, async: true

  alias MatsuriOps.Cameras.Camera

  describe "changeset/2" do
    test "valid changeset with required fields" do
      changeset = Camera.changeset(%Camera{}, %{
        name: "メインカメラ",
        stream_url: "https://stream.example.com/cam1",
        stream_type: "hls"
      })

      assert changeset.valid?
    end

    test "invalid changeset without name" do
      changeset = Camera.changeset(%Camera{}, %{
        stream_url: "https://stream.example.com/cam1",
        stream_type: "hls"
      })

      refute changeset.valid?
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid changeset with invalid stream_type" do
      changeset = Camera.changeset(%Camera{}, %{
        name: "カメラ",
        stream_url: "https://stream.example.com/cam1",
        stream_type: "invalid"
      })

      refute changeset.valid?
      assert %{stream_type: ["is invalid"]} = errors_on(changeset)
    end

    test "invalid changeset with invalid status" do
      changeset = Camera.changeset(%Camera{}, %{
        name: "カメラ",
        stream_url: "https://stream.example.com/cam1",
        stream_type: "hls",
        status: "invalid"
      })

      refute changeset.valid?
    end

    test "valid changeset with rtsp stream URL" do
      changeset = Camera.changeset(%Camera{}, %{
        name: "カメラ",
        stream_url: "rtsp://stream.example.com/cam1",
        stream_type: "rtsp"
      })

      assert changeset.valid?
    end

    test "valid changeset with all optional fields" do
      changeset = Camera.changeset(%Camera{}, %{
        name: "メインカメラ",
        description: "会場正面",
        stream_url: "https://stream.example.com/cam1",
        stream_type: "hls",
        location: "正門前",
        latitude: 35.6762,
        longitude: 139.6503,
        status: "online",
        thumbnail_url: "https://example.com/thumb.jpg",
        settings: %{"resolution" => "1080p"}
      })

      assert changeset.valid?
    end
  end

  describe "stream_types/0" do
    test "returns all valid stream types" do
      types = Camera.stream_types()
      assert "hls" in types
      assert "rtsp" in types
      assert "webrtc" in types
      assert "mjpeg" in types
    end
  end

  describe "statuses/0" do
    test "returns all valid statuses" do
      statuses = Camera.statuses()
      assert "online" in statuses
      assert "offline" in statuses
      assert "error" in statuses
      assert "maintenance" in statuses
    end
  end
end
