defmodule MatsuriOps.Sponsorships.Sponsorship do
  @moduledoc """
  協賛契約スキーマ。

  祭りと協賛企業間の協賛契約を管理する。
  """

  use Ecto.Schema
  import Ecto.Changeset

  @tiers ~w(platinum gold silver bronze supporter)
  @payment_statuses ~w(pending partial paid cancelled refunded)

  schema "sponsorships" do
    field :tier, :string
    field :amount, :integer
    field :payment_status, :string, default: "pending"
    field :contract_date, :date
    field :payment_date, :date
    field :notes, :string

    belongs_to :festival, MatsuriOps.Festivals.Festival
    belongs_to :sponsor, MatsuriOps.Sponsorships.Sponsor
    has_many :benefits, MatsuriOps.Sponsorships.SponsorBenefit

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(sponsorship, attrs) do
    sponsorship
    |> cast(attrs, [:tier, :amount, :payment_status, :contract_date, :payment_date, :notes])
    |> validate_required([:tier, :amount])
    |> validate_inclusion(:tier, @tiers)
    |> validate_inclusion(:payment_status, @payment_statuses)
    |> validate_number(:amount, greater_than: 0)
  end

  def tiers, do: @tiers
  def payment_statuses, do: @payment_statuses
end
