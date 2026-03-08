defmodule MatsuriOps.Sponsorships.Sponsor do
  @moduledoc """
  協賛企業スキーマ。

  協賛企業の連絡先や詳細情報を管理する。
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "sponsors" do
    field :name, :string
    field :contact_name, :string
    field :contact_email, :string
    field :contact_phone, :string
    field :address, :string
    field :industry, :string
    field :website, :string
    field :logo_url, :string
    field :notes, :string

    has_many :sponsorships, MatsuriOps.Sponsorships.Sponsorship

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(sponsor, attrs) do
    sponsor
    |> cast(attrs, [
      :name,
      :contact_name,
      :contact_email,
      :contact_phone,
      :address,
      :industry,
      :website,
      :logo_url,
      :notes
    ])
    |> validate_required([:name])
    |> validate_format(:contact_email, ~r/^[^\s]+@[^\s]+$/, message: "は有効なメールアドレスである必要があります")
    |> validate_format(:website, ~r/^https?:\/\//, message: "は有効なURLである必要があります")
  end
end
