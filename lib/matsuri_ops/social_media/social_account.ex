defmodule MatsuriOps.SocialMedia.SocialAccount do
  @moduledoc """
  ソーシャルアカウントスキーマ。

  SNS連携用のアカウント情報を管理する。
  """

  use Ecto.Schema
  import Ecto.Changeset

  @platforms ["twitter", "instagram", "facebook"]

  schema "social_accounts" do
    field :platform, :string
    field :account_name, :string
    field :account_id, :string
    field :access_token, :string
    field :refresh_token, :string
    field :expires_at, :utc_datetime
    field :is_active, :boolean, default: true

    belongs_to :festival, MatsuriOps.Festivals.Festival

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(social_account, attrs) do
    social_account
    |> cast(attrs, [
      :platform,
      :account_name,
      :account_id,
      :access_token,
      :refresh_token,
      :expires_at,
      :is_active,
      :festival_id
    ])
    |> validate_required([:platform, :account_name, :festival_id])
    |> validate_inclusion(:platform, @platforms)
    |> foreign_key_constraint(:festival_id)
    |> unique_constraint([:festival_id, :platform, :account_id])
  end

  @doc """
  利用可能なプラットフォームを返す。
  """
  def platforms, do: @platforms

  @doc """
  プラットフォームのラベルを返す。
  """
  def platform_label("twitter"), do: "X (Twitter)"
  def platform_label("instagram"), do: "Instagram"
  def platform_label("facebook"), do: "Facebook"
  def platform_label(_), do: "不明"

  @doc """
  プラットフォームのアイコンカラーを返す。
  """
  def platform_color("twitter"), do: "bg-black"
  def platform_color("instagram"), do: "bg-gradient-to-r from-purple-500 to-pink-500"
  def platform_color("facebook"), do: "bg-blue-600"
  def platform_color(_), do: "bg-gray-500"

  @doc """
  トークンが有効期限内かどうかを返す。
  """
  def token_valid?(%__MODULE__{expires_at: nil}), do: true
  def token_valid?(%__MODULE__{expires_at: expires_at}) do
    DateTime.compare(expires_at, DateTime.utc_now()) == :gt
  end
end
