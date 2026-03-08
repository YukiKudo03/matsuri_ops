defmodule MatsuriOps.Sponsorships.SponsorBenefit do
  @moduledoc """
  協賛特典スキーマ。

  協賛企業への特典（ロゴ掲載、ブース提供など）を管理する。
  """

  use Ecto.Schema
  import Ecto.Changeset

  @statuses ~w(pending in_progress completed cancelled)

  schema "sponsor_benefits" do
    field :name, :string
    field :description, :string
    field :status, :string, default: "pending"
    field :completed_at, :utc_datetime

    belongs_to :sponsorship, MatsuriOps.Sponsorships.Sponsorship

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(benefit, attrs) do
    benefit
    |> cast(attrs, [:name, :description, :status, :completed_at])
    |> validate_required([:name, :status])
    |> validate_inclusion(:status, @statuses)
  end

  def statuses, do: @statuses
end
