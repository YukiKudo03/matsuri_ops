defmodule MatsuriOps.Notifications.Announcement do
  @moduledoc """
  お知らせスキーマ。

  祭りに関連するお知らせ・通知を管理する。
  """

  use Ecto.Schema
  import Ecto.Changeset

  @priorities ~w(low normal high urgent)
  @target_audiences ~w(all staff admin)

  schema "announcements" do
    field :title, :string
    field :content, :string
    field :priority, :string, default: "normal"
    field :target_audience, :string, default: "all"
    field :expires_at, :utc_datetime

    belongs_to :festival, MatsuriOps.Festivals.Festival
    belongs_to :created_by, MatsuriOps.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(announcement, attrs) do
    announcement
    |> cast(attrs, [:title, :content, :priority, :target_audience, :expires_at, :festival_id, :created_by_id])
    |> validate_required([:title, :content, :festival_id])
    |> validate_inclusion(:priority, @priorities)
    |> validate_inclusion(:target_audience, @target_audiences)
    |> foreign_key_constraint(:festival_id)
    |> foreign_key_constraint(:created_by_id)
  end

  def priorities, do: @priorities
  def target_audiences, do: @target_audiences
end
