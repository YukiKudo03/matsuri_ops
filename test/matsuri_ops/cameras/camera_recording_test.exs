defmodule MatsuriOps.Cameras.CameraRecordingTest do
  use MatsuriOps.DataCase, async: true

  alias MatsuriOps.Cameras.CameraRecording

  describe "changeset/2" do
    test "valid changeset with required fields" do
      changeset = CameraRecording.changeset(%CameraRecording{}, %{
        status: "recording",
        started_at: DateTime.utc_now()
      })

      assert changeset.valid?
    end

    test "invalid changeset without status" do
      _changeset = CameraRecording.changeset(%CameraRecording{}, %{
        started_at: DateTime.utc_now()
      })

      # status has a default so it won't fail on required
      # but validate explicitly removing it
      changeset2 = CameraRecording.changeset(%CameraRecording{}, %{status: nil, started_at: DateTime.utc_now()})
      refute changeset2.valid?
    end

    test "invalid changeset without started_at" do
      changeset = CameraRecording.changeset(%CameraRecording{}, %{status: "recording"})
      refute changeset.valid?
      assert %{started_at: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid changeset with invalid status" do
      changeset = CameraRecording.changeset(%CameraRecording{}, %{
        status: "invalid",
        started_at: DateTime.utc_now()
      })

      refute changeset.valid?
      assert %{status: ["is invalid"]} = errors_on(changeset)
    end

    test "valid changeset with all fields" do
      changeset = CameraRecording.changeset(%CameraRecording{}, %{
        status: "completed",
        started_at: DateTime.utc_now() |> DateTime.add(-3600),
        ended_at: DateTime.utc_now(),
        file_path: "/recordings/cam1_20260815.mp4",
        file_size: 1024 * 1024 * 100,
        duration_seconds: 3600
      })

      assert changeset.valid?
    end
  end

  describe "statuses/0" do
    test "returns all valid statuses" do
      statuses = CameraRecording.statuses()
      assert "recording" in statuses
      assert "completed" in statuses
      assert "failed" in statuses
      assert "cancelled" in statuses
    end
  end
end
