defmodule MatsuriOps.Advertising do
  @moduledoc """
  広告管理コンテキスト。

  広告バナーの管理、表示、トラッキング機能を提供する。
  """

  import Ecto.Query, warn: false
  alias MatsuriOps.Repo
  alias MatsuriOps.Advertising.AdBanner

  @doc """
  祭りに関連する広告バナー一覧を取得する。
  """
  def list_ad_banners(festival_id) do
    AdBanner
    |> where([b], b.festival_id == ^festival_id)
    |> order_by([b], [desc: b.display_weight, asc: b.inserted_at])
    |> preload(:sponsor)
    |> Repo.all()
  end

  @doc """
  アクティブな広告バナー一覧を取得する。
  """
  def list_active_banners(festival_id) do
    today = Date.utc_today()

    AdBanner
    |> where([b], b.festival_id == ^festival_id)
    |> where([b], b.is_active == true)
    |> where([b], is_nil(b.start_date) or b.start_date <= ^today)
    |> where([b], is_nil(b.end_date) or b.end_date >= ^today)
    |> order_by([b], [desc: b.display_weight])
    |> preload(:sponsor)
    |> Repo.all()
  end

  @doc """
  ポジションでフィルタしたアクティブな広告バナーを取得する。
  """
  def list_active_banners_by_position(festival_id, position) do
    today = Date.utc_today()

    AdBanner
    |> where([b], b.festival_id == ^festival_id)
    |> where([b], b.position == ^position)
    |> where([b], b.is_active == true)
    |> where([b], is_nil(b.start_date) or b.start_date <= ^today)
    |> where([b], is_nil(b.end_date) or b.end_date >= ^today)
    |> order_by([b], [desc: b.display_weight])
    |> preload(:sponsor)
    |> Repo.all()
  end

  @doc """
  スポンサーでフィルタした広告バナーを取得する。
  """
  def list_banners_by_sponsor(sponsor_id) do
    AdBanner
    |> where([b], b.sponsor_id == ^sponsor_id)
    |> order_by([b], [desc: b.inserted_at])
    |> preload(:sponsor)
    |> Repo.all()
  end

  @doc """
  広告バナーを取得する。

  見つからない場合は`Ecto.NoResultsError`を発生させる。
  """
  def get_ad_banner!(id) do
    AdBanner
    |> Repo.get!(id)
    |> Repo.preload(:sponsor)
  end

  @doc """
  広告バナーを取得する。見つからない場合はnilを返す。
  """
  def get_ad_banner(id), do: Repo.get(AdBanner, id)

  @doc """
  広告バナーを作成する。
  """
  def create_ad_banner(attrs \\ %{}) do
    %AdBanner{}
    |> AdBanner.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  広告バナーを更新する。
  """
  def update_ad_banner(%AdBanner{} = ad_banner, attrs) do
    ad_banner
    |> AdBanner.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  広告バナーを削除する。
  """
  def delete_ad_banner(%AdBanner{} = ad_banner) do
    Repo.delete(ad_banner)
  end

  @doc """
  広告バナーの変更用changesetを返す。
  """
  def change_ad_banner(%AdBanner{} = ad_banner, attrs \\ %{}) do
    AdBanner.changeset(ad_banner, attrs)
  end

  @doc """
  クリック数をインクリメントする。
  """
  def increment_click(%AdBanner{} = ad_banner) do
    ad_banner
    |> AdBanner.increment_click_changeset()
    |> Repo.update()
  end

  def increment_click(id) when is_integer(id) or is_binary(id) do
    case get_ad_banner(id) do
      nil -> {:error, :not_found}
      ad_banner -> increment_click(ad_banner)
    end
  end

  @doc """
  インプレッション数をインクリメントする。
  """
  def increment_impression(%AdBanner{} = ad_banner) do
    ad_banner
    |> AdBanner.increment_impression_changeset()
    |> Repo.update()
  end

  @doc """
  バナーのアクティブ状態を切り替える。
  """
  def toggle_active(%AdBanner{} = ad_banner) do
    ad_banner
    |> Ecto.Changeset.change(is_active: !ad_banner.is_active)
    |> Repo.update()
  end

  @doc """
  祭りの広告バナー統計を取得する。
  """
  def get_statistics(festival_id) do
    stats =
      AdBanner
      |> where([b], b.festival_id == ^festival_id)
      |> select([b], %{
        total_count: count(b.id),
        active_count: sum(fragment("CASE WHEN ? THEN 1 ELSE 0 END", b.is_active)),
        total_clicks: sum(b.click_count),
        total_impressions: sum(b.impression_count)
      })
      |> Repo.one()

    position_stats =
      AdBanner
      |> where([b], b.festival_id == ^festival_id)
      |> group_by([b], b.position)
      |> select([b], {b.position, count(b.id)})
      |> Repo.all()
      |> Enum.into(%{})

    %{
      total_count: stats.total_count || 0,
      active_count: stats.active_count || 0,
      total_clicks: stats.total_clicks || 0,
      total_impressions: stats.total_impressions || 0,
      by_position: position_stats
    }
  end

  @doc """
  クリック率（CTR）を計算する。
  """
  def calculate_ctr(%AdBanner{impression_count: 0}), do: 0.0

  def calculate_ctr(%AdBanner{click_count: clicks, impression_count: impressions}) do
    Float.round(clicks / impressions * 100, 2)
  end

  @doc """
  重み付けランダムでバナーを選択する。
  """
  def select_weighted_banner(banners) when is_list(banners) and length(banners) > 0 do
    total_weight = Enum.sum(Enum.map(banners, & &1.display_weight))
    random_value = :rand.uniform() * total_weight

    {selected, _} =
      Enum.reduce_while(banners, {nil, 0}, fn banner, {_, accumulated} ->
        new_accumulated = accumulated + banner.display_weight

        if random_value <= new_accumulated do
          {:halt, {banner, new_accumulated}}
        else
          {:cont, {nil, new_accumulated}}
        end
      end)

    selected || List.first(banners)
  end

  def select_weighted_banner(_), do: nil
end
