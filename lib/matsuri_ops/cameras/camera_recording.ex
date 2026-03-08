defmodule MatsuriOps.Cameras.CameraRecording do
  @moduledoc """
  カメラ録画スキーマ。

  カメラ映像の録画セッションを管理する。
  """

  use Ecto.Schema
  import Ecto.Changeset

  @statuses ~w(recording completed failed cancelled)

  schema "camera_recordings" do
    field :status, :string, default: "recording"
    field :started_at, :utc_datetime
    field :ended_at, :utc_datetime
    field :file_path, :string
    field :file_size, :integer
    field :duration_seconds, :integer

    belongs_to :camera, MatsuriOps.Cameras.Camera

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(recording, attrs) do
    recording
    |> cast(attrs, [:status, :started_at, :ended_at, :file_path, :file_size, :duration_seconds])
    |> validate_required([:status, :started_at])
    |> validate_inclusion(:status, @statuses)
  end

  def statuses, do: @statuses
end
