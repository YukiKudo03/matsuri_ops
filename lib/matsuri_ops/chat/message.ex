defmodule MatsuriOps.Chat.Message do
  @moduledoc """
  チャットメッセージスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :content, :string
    field :message_type, :string, default: "text"

    belongs_to :chat_room, MatsuriOps.Chat.ChatRoom
    belongs_to :user, MatsuriOps.Accounts.User
    has_many :read_statuses, MatsuriOps.Chat.ReadStatus

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :message_type, :chat_room_id, :user_id])
    |> validate_required([:content, :chat_room_id, :user_id])
    |> validate_length(:content, min: 1, max: 5000)
    |> validate_inclusion(:message_type, ["text", "image", "file", "system"])
    |> foreign_key_constraint(:chat_room_id)
    |> foreign_key_constraint(:user_id)
  end
end
