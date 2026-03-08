defmodule MatsuriOps.Advertising.AdBanner do
  @moduledoc """
  広告バナースキーマ。

  スポンサー広告バナーの表示管理を行う。
  """

  use Ecto.Schema
  import Ecto.Changeset

  @positions ["header", "sidebar", "footer", "popup"]

  schema "ad_banners" do
    field :name, :string
    field :image_url, :string
    field :link_url, :string
    field :position, :string, default: "sidebar"
    field :display_weight, :integer, default: 10
    field :start_date, :date
    field :end_date, :date
    field :click_count, :integer, default: 0
    field :impression_count, :integer, default: 0
    field :is_active, :boolean, default: true

    belongs_to :festival, MatsuriOps.Festivals.Festival
    belongs_to :sponsor, MatsuriOps.Sponsorships.Sponsor

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(ad_banner, attrs) do
    ad_banner
    |> cast(attrs, [
      :name,
      :image_url,
      :link_url,
      :position,
      :display_weight,
      :start_date,
      :end_date,
      :is_active,
      :festival_id,
      :sponsor_id
    ])
    |> validate_required([:name, :festival_id])
    |> validate_inclusion(:position, @positions)
    |> validate_number(:display_weight, greater_than: 0, less_than_or_equal_to: 100)
    |> validate_url(:link_url)
    |> validate_dates()
    |> foreign_key_constraint(:festival_id)
    |> foreign_key_constraint(:sponsor_id)
  end

  @doc """
  クリック数インクリメント用changeset。
  """
  def increment_click_changeset(ad_banner) do
    change(ad_banner, click_count: ad_banner.click_count + 1)
  end

  @doc """
  インプレッション数インクリメント用changeset。
  """
  def increment_impression_changeset(ad_banner) do
    change(ad_banner, impression_count: ad_banner.impression_count + 1)
  end

  @doc """
  利用可能なポジションを返す。
  """
  def positions, do: @positions

  @doc """
  ポジションのラベルを返す。
  """
  def position_label("header"), do: "ヘッダー"
  def position_label("sidebar"), do: "サイドバー"
  def position_label("footer"), do: "フッター"
  def position_label("popup"), do: "ポップアップ"
  def position_label(_), do: "不明"

  defp validate_url(changeset, field) do
    validate_change(changeset, field, fn _, value ->
      if is_nil(value) || value == "" || String.match?(value, ~r/^https?:\/\/.+/) do
        []
      else
        [{field, "有効なURLを入力してください"}]
      end
    end)
  end

  defp validate_dates(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)

    cond do
      is_nil(start_date) || is_nil(end_date) ->
        changeset

      Date.compare(end_date, start_date) == :lt ->
        add_error(changeset, :end_date, "は開始日より後の日付を指定してください")

      true ->
        changeset
    end
  end
end
