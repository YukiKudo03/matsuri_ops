defmodule MatsuriOps.Chat.ReadStatus do
  @moduledoc """
  既読状態スキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "read_statuses" do
    field :read_at, :utc_datetime

    belongs_to :message, MatsuriOps.Chat.Message
    belongs_to :user, MatsuriOps.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(read_status, attrs) do
    read_status
    |> cast(attrs, [:read_at, :message_id, :user_id])
    |> validate_required([:read_at, :message_id, :user_id])
    |> unique_constraint([:message_id, :user_id])
    |> foreign_key_constraint(:message_id)
    |> foreign_key_constraint(:user_id)
  end
end
