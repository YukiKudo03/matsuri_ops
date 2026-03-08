defmodule MatsuriOps.Templates.Template do
  @moduledoc """
  テンプレートスキーマ。

  テンプレートは祭りを作成するための雛形で、デフォルトの設定値を持つ。
  テンプレートを適用して新しい祭りを作成したり、既存の祭りからテンプレートを作成できる。
  """

  use Ecto.Schema
  import Ecto.Changeset

  @scales ~w(small medium large)

  schema "templates" do
    field :name, :string
    field :description, :string
    field :scale, :string, default: "medium"
    field :default_expected_visitors, :integer
    field :default_expected_vendors, :integer
    field :is_public, :boolean, default: false

    belongs_to :creator, MatsuriOps.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def scales, do: @scales

  def changeset(template, attrs) do
    template
    |> cast(attrs, [
      :name,
      :description,
      :scale,
      :default_expected_visitors,
      :default_expected_vendors,
      :is_public
    ])
    |> validate_required([:name])
    |> validate_inclusion(:scale, @scales)
    |> validate_number(:default_expected_visitors, greater_than_or_equal_to: 0)
    |> validate_number(:default_expected_vendors, greater_than_or_equal_to: 0)
  end
end
