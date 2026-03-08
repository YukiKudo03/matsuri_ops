defmodule MatsuriOps.Notifications.PushSubscription do
  @moduledoc """
  プッシュ通知購読スキーマ。

  Web Push APIのサブスクリプション情報を管理する。
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "push_subscriptions" do
    field :endpoint, :string
    field :p256dh_key, :string
    field :auth_key, :string

    belongs_to :user, MatsuriOps.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:endpoint, :p256dh_key, :auth_key, :user_id])
    |> validate_required([:endpoint, :p256dh_key, :auth_key, :user_id])
    |> unique_constraint(:endpoint)
    |> foreign_key_constraint(:user_id)
  end
end
