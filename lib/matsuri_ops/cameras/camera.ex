defmodule MatsuriOps.Cameras.Camera do
  @moduledoc """
  ライブカメラスキーマ。

  会場に設置されたカメラの情報とストリーミング設定を管理する。
  """

  use Ecto.Schema
  import Ecto.Changeset

  @stream_types ~w(hls rtsp webrtc mjpeg)
  @statuses ~w(online offline error maintenance)

  schema "cameras" do
    field :name, :string
    field :description, :string
    field :stream_url, :string
    field :stream_type, :string, default: "hls"
    field :location, :string
    field :latitude, :float
    field :longitude, :float
    field :status, :string, default: "offline"
    field :thumbnail_url, :string
    field :settings, :map, default: %{}

    belongs_to :festival, MatsuriOps.Festivals.Festival
    has_many :recordings, MatsuriOps.Cameras.CameraRecording

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(camera, attrs) do
    camera
    |> cast(attrs, [
      :name,
      :description,
      :stream_url,
      :stream_type,
      :location,
      :latitude,
      :longitude,
      :status,
      :thumbnail_url,
      :settings
    ])
    |> validate_required([:name, :stream_url, :stream_type])
    |> validate_inclusion(:stream_type, @stream_types)
    |> validate_inclusion(:status, @statuses)
    |> validate_url(:stream_url)
  end

  defp validate_url(changeset, field) do
    validate_change(changeset, field, fn _, url ->
      case URI.parse(url) do
        %URI{scheme: scheme} when scheme in ["http", "https", "rtsp", "rtmp"] ->
          []

        _ ->
          [{field, "は有効なURLである必要があります"}]
      end
    end)
  end

  def stream_types, do: @stream_types
  def statuses, do: @statuses
end
