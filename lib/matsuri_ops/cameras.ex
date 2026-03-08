defmodule MatsuriOps.Cameras do
  @moduledoc """
  ライブカメラ連携コンテキスト。

  会場のライブカメラ映像の管理、ストリーミング、録画機能を提供する。
  """

  import Ecto.Query, warn: false
  alias MatsuriOps.Repo
  alias MatsuriOps.Cameras.{Camera, CameraRecording}

  # =====================
  # Camera CRUD
  # =====================

  @doc """
  祭りのカメラ一覧を取得する。
  """
  def list_cameras(festival_id) do
    Camera
    |> where([c], c.festival_id == ^festival_id)
    |> order_by([c], [asc: c.name])
    |> Repo.all()
  end

  @doc """
  オンラインのカメラのみを取得する。
  """
  def list_online_cameras(festival_id) do
    Camera
    |> where([c], c.festival_id == ^festival_id)
    |> where([c], c.status == "online")
    |> order_by([c], [asc: c.name])
    |> Repo.all()
  end

  @doc """
  カメラを取得する。
  """
  def get_camera!(id), do: Repo.get!(Camera, id)

  @doc """
  カメラを作成する。
  """
  def create_camera(festival, attrs \\ %{}) do
    %Camera{}
    |> Camera.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:festival, festival)
    |> Repo.insert()
  end

  @doc """
  カメラを更新する。
  """
  def update_camera(%Camera{} = camera, attrs) do
    camera
    |> Camera.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  カメラを削除する。
  """
  def delete_camera(%Camera{} = camera) do
    Repo.delete(camera)
  end

  @doc """
  カメラのchangesetを返す。
  """
  def change_camera(%Camera{} = camera, attrs \\ %{}) do
    Camera.changeset(camera, attrs)
  end

  # =====================
  # Camera Status
  # =====================

  @doc """
  カメラのステータスを更新する。
  """
  def update_camera_status(%Camera{} = camera, status) do
    camera
    |> Camera.changeset(%{status: status})
    |> Repo.update()
  end

  @doc """
  カメラの健全性をチェックする。
  """
  def check_camera_health(%Camera{} = camera) do
    # 実際の実装ではHTTPリクエストでストリームの状態を確認
    # モック環境ではデフォルト値を返す
    health = %{
      status: :unknown,
      latency_ms: nil,
      last_checked: DateTime.utc_now(),
      stream_url: camera.stream_url
    }

    {:ok, health}
  end

  # =====================
  # Stream Configuration
  # =====================

  @doc """
  サポートされているストリームタイプを返す。
  """
  def supported_stream_types do
    Camera.stream_types()
  end

  @doc """
  ストリームタイプに応じたプレイヤー設定を返す。
  """
  def stream_player_config("hls") do
    %{
      player: "hls.js",
      autoplay: false,
      controls: true,
      muted: true,
      options: %{
        enableWorker: true,
        lowLatencyMode: true
      }
    }
  end

  def stream_player_config("rtsp") do
    %{
      player: "jsmpeg",
      autoplay: false,
      controls: true,
      muted: true,
      options: %{
        websocket_url: nil
      }
    }
  end

  def stream_player_config("webrtc") do
    %{
      player: "webrtc",
      autoplay: false,
      controls: true,
      muted: true,
      options: %{
        ice_servers: [%{urls: "stun:stun.l.google.com:19302"}]
      }
    }
  end

  def stream_player_config("mjpeg") do
    %{
      player: "img",
      autoplay: true,
      controls: false,
      muted: true,
      options: %{
        refresh_rate: 100
      }
    }
  end

  def stream_player_config(_), do: %{player: "video", autoplay: false, controls: true, muted: true, options: %{}}

  # =====================
  # Recording
  # =====================

  @doc """
  録画を開始する。
  """
  def start_recording(%Camera{} = camera) do
    %CameraRecording{}
    |> CameraRecording.changeset(%{
      status: "recording",
      started_at: DateTime.utc_now()
    })
    |> Ecto.Changeset.put_assoc(:camera, camera)
    |> Repo.insert()
  end

  @doc """
  録画を停止する。
  """
  def stop_recording(%CameraRecording{} = recording) do
    ended_at = DateTime.utc_now()
    duration = DateTime.diff(ended_at, recording.started_at, :second)

    recording
    |> CameraRecording.changeset(%{
      status: "completed",
      ended_at: ended_at,
      duration_seconds: duration
    })
    |> Repo.update()
  end

  @doc """
  カメラの録画一覧を取得する。
  """
  def list_recordings(camera_id) do
    CameraRecording
    |> where([r], r.camera_id == ^camera_id)
    |> order_by([r], [desc: r.started_at])
    |> Repo.all()
  end

  @doc """
  録画を取得する。
  """
  def get_recording!(id), do: Repo.get!(CameraRecording, id)

  @doc """
  録画を削除する。
  """
  def delete_recording(%CameraRecording{} = recording) do
    Repo.delete(recording)
  end

  # =====================
  # PubSub
  # =====================

  @doc """
  カメラ更新をブロードキャストする。
  """
  def broadcast_camera_update(%Camera{} = camera) do
    Phoenix.PubSub.broadcast(
      MatsuriOps.PubSub,
      "cameras:#{camera.festival_id}",
      {:camera_updated, camera}
    )
  end

  @doc """
  カメラチャンネルを購読する。
  """
  def subscribe_cameras(festival_id) do
    Phoenix.PubSub.subscribe(MatsuriOps.PubSub, "cameras:#{festival_id}")
  end
end
