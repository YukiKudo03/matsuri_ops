defmodule MatsuriOps.Sponsorships do
  @moduledoc """
  協賛金管理コンテキスト。

  協賛企業、協賛契約、協賛特典の管理機能を提供する。
  """

  import Ecto.Query, warn: false
  alias MatsuriOps.Repo
  alias MatsuriOps.Sponsorships.{Sponsor, Sponsorship, SponsorBenefit}

  # =====================
  # Sponsor CRUD
  # =====================

  @doc """
  全ての協賛企業を取得する。
  """
  def list_sponsors do
    Sponsor
    |> order_by([s], [asc: s.name])
    |> Repo.all()
  end

  @doc """
  協賛企業を名前で検索する。
  """
  def search_sponsors(query) do
    search_term = "%#{query}%"

    Sponsor
    |> where([s], ilike(s.name, ^search_term))
    |> order_by([s], [asc: s.name])
    |> Repo.all()
  end

  @doc """
  協賛企業を取得する。
  """
  def get_sponsor!(id), do: Repo.get!(Sponsor, id)

  @doc """
  協賛企業を作成する。
  """
  def create_sponsor(attrs \\ %{}) do
    %Sponsor{}
    |> Sponsor.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  協賛企業を更新する。
  """
  def update_sponsor(%Sponsor{} = sponsor, attrs) do
    sponsor
    |> Sponsor.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  協賛企業を削除する。
  """
  def delete_sponsor(%Sponsor{} = sponsor) do
    Repo.delete(sponsor)
  end

  @doc """
  協賛企業のchangesetを返す。
  """
  def change_sponsor(%Sponsor{} = sponsor, attrs \\ %{}) do
    Sponsor.changeset(sponsor, attrs)
  end

  # =====================
  # Sponsorship CRUD
  # =====================

  @doc """
  祭りの協賛契約一覧を取得する。
  """
  def list_sponsorships(festival_id) do
    Sponsorship
    |> where([s], s.festival_id == ^festival_id)
    |> preload(:sponsor)
    |> order_by([s], [desc: s.amount])
    |> Repo.all()
  end

  @doc """
  ティアでフィルタリングした協賛契約を取得する。
  """
  def list_sponsorships_by_tier(festival_id, tier) do
    Sponsorship
    |> where([s], s.festival_id == ^festival_id)
    |> where([s], s.tier == ^tier)
    |> preload(:sponsor)
    |> Repo.all()
  end

  @doc """
  協賛契約を取得する。
  """
  def get_sponsorship!(id), do: Repo.get!(Sponsorship, id) |> Repo.preload(:sponsor)

  @doc """
  協賛契約を作成する。
  """
  def create_sponsorship(festival, sponsor, attrs \\ %{}) do
    %Sponsorship{}
    |> Sponsorship.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:festival, festival)
    |> Ecto.Changeset.put_assoc(:sponsor, sponsor)
    |> Repo.insert()
  end

  @doc """
  協賛契約を更新する。
  """
  def update_sponsorship(%Sponsorship{} = sponsorship, attrs) do
    sponsorship
    |> Sponsorship.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  協賛契約を削除する。
  """
  def delete_sponsorship(%Sponsorship{} = sponsorship) do
    Repo.delete(sponsorship)
  end

  @doc """
  協賛契約のchangesetを返す。
  """
  def change_sponsorship(%Sponsorship{} = sponsorship, attrs \\ %{}) do
    Sponsorship.changeset(sponsorship, attrs)
  end

  # =====================
  # Sponsorship Tiers
  # =====================

  @doc """
  利用可能なティアを返す。
  """
  def available_tiers do
    Sponsorship.tiers()
  end

  @doc """
  ティアの特典一覧を返す。
  """
  def tier_benefits("platinum") do
    [
      "メインステージでの企業紹介",
      "パンフレット表紙へのロゴ掲載",
      "VIPブースの提供",
      "公式サイトトップへのバナー掲載",
      "SNS での優先的な紹介",
      "来賓としての招待（10名）"
    ]
  end

  def tier_benefits("gold") do
    [
      "パンフレットへのロゴ掲載（大）",
      "会場内看板への掲載",
      "公式サイトへのロゴ掲載",
      "SNSでの紹介",
      "来賓としての招待（5名）"
    ]
  end

  def tier_benefits("silver") do
    [
      "パンフレットへのロゴ掲載（中）",
      "公式サイトへのロゴ掲載",
      "来賓としての招待（3名）"
    ]
  end

  def tier_benefits("bronze") do
    [
      "パンフレットへのロゴ掲載（小）",
      "来賓としての招待（2名）"
    ]
  end

  def tier_benefits("supporter") do
    [
      "パンフレットへの企業名掲載",
      "来賓としての招待（1名）"
    ]
  end

  def tier_benefits(_), do: []

  @doc """
  ティアの最低協賛金額を返す。
  """
  def minimum_amount("platinum"), do: 1_000_000
  def minimum_amount("gold"), do: 500_000
  def minimum_amount("silver"), do: 300_000
  def minimum_amount("bronze"), do: 100_000
  def minimum_amount("supporter"), do: 50_000
  def minimum_amount(_), do: 0

  # =====================
  # Statistics
  # =====================

  @doc """
  祭りの協賛金総額を計算する。
  """
  def total_sponsorship_amount(festival_id) do
    Sponsorship
    |> where([s], s.festival_id == ^festival_id)
    |> select([s], sum(s.amount))
    |> Repo.one()
    |> Kernel.||(0)
  end

  @doc """
  協賛サマリーを取得する。
  """
  def sponsorship_summary(festival_id) do
    sponsorships = list_sponsorships(festival_id)

    by_tier =
      sponsorships
      |> Enum.group_by(& &1.tier)
      |> Enum.map(fn {tier, items} ->
        {tier, %{
          count: length(items),
          total_amount: Enum.sum(Enum.map(items, & &1.amount))
        }}
      end)
      |> Map.new()

    %{
      total_amount: Enum.sum(Enum.map(sponsorships, & &1.amount)),
      sponsor_count: length(sponsorships),
      by_tier: by_tier
    }
  end

  @doc """
  支払いステータス別のサマリーを取得する。
  """
  def payment_status_summary(festival_id) do
    sponsorships = list_sponsorships(festival_id)

    paid = Enum.filter(sponsorships, &(&1.payment_status == "paid"))
    pending = Enum.filter(sponsorships, &(&1.payment_status == "pending"))
    partial = Enum.filter(sponsorships, &(&1.payment_status == "partial"))

    %{
      paid_amount: Enum.sum(Enum.map(paid, & &1.amount)),
      paid_count: length(paid),
      pending_amount: Enum.sum(Enum.map(pending, & &1.amount)),
      pending_count: length(pending),
      partial_amount: Enum.sum(Enum.map(partial, & &1.amount)),
      partial_count: length(partial)
    }
  end

  # =====================
  # Benefits
  # =====================

  @doc """
  協賛特典を追加する。
  """
  def add_benefit(%Sponsorship{} = sponsorship, attrs) do
    %SponsorBenefit{}
    |> SponsorBenefit.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:sponsorship, sponsorship)
    |> Repo.insert()
  end

  @doc """
  協賛特典一覧を取得する。
  """
  def list_benefits(sponsorship_id) do
    SponsorBenefit
    |> where([b], b.sponsorship_id == ^sponsorship_id)
    |> order_by([b], [asc: b.inserted_at])
    |> Repo.all()
  end

  @doc """
  特典のステータスを更新する。
  """
  def update_benefit_status(%SponsorBenefit{} = benefit, status) do
    attrs =
      if status == "completed" do
        %{status: status, completed_at: DateTime.utc_now()}
      else
        %{status: status}
      end

    benefit
    |> SponsorBenefit.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  特典を削除する。
  """
  def delete_benefit(%SponsorBenefit{} = benefit) do
    Repo.delete(benefit)
  end
end
