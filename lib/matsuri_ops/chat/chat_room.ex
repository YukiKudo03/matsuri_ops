defmodule MatsuriOps.Chat.ChatRoom do
  @moduledoc """
  チャットルームスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_rooms" do
    field :name, :string
    field :room_type, :string, default: "general"
    field :description, :string

    belongs_to :festival, MatsuriOps.Festivals.Festival
    has_many :messages, MatsuriOps.Chat.Message

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(chat_room, attrs) do
    chat_room
    |> cast(attrs, [:name, :room_type, :description, :festival_id])
    |> validate_required([:name, :room_type, :festival_id])
    |> validate_inclusion(:room_type, ["general", "emergency", "staff", "vendor"])
    |> foreign_key_constraint(:festival_id)
  end
end
