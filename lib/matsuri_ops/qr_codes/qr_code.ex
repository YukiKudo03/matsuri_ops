defmodule MatsuriOps.QRCodes.QRCode do
  @moduledoc """
  QRコードスキーマ。

  ## code_type

  - `ticket` - チケット用QR
  - `location` - 会場案内QR
  - `vendor` - 出店者情報QR
  - `info` - 一般情報QR
  - `custom` - カスタムQR
  """

  use Ecto.Schema
  import Ecto.Changeset

  @code_types ~w(ticket location vendor info custom)

  schema "qr_codes" do
    field :name, :string
    field :code_type, :string, default: "custom"
    field :target_url, :string
    field :svg_data, :string
    field :scan_count, :integer, default: 0

    belongs_to :festival, MatsuriOps.Festivals.Festival

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(qr_code, attrs) do
    qr_code
    |> cast(attrs, [:name, :code_type, :target_url, :svg_data, :scan_count, :festival_id])
    |> validate_required([:name, :code_type, :target_url, :festival_id])
    |> validate_inclusion(:code_type, @code_types)
    |> validate_url(:target_url)
    |> foreign_key_constraint(:festival_id)
  end

  @doc """
  スキャン回数をインクリメントするためのchangeset。
  """
  def increment_scan_changeset(qr_code) do
    change(qr_code, scan_count: (qr_code.scan_count || 0) + 1)
  end

  defp validate_url(changeset, field) do
    validate_change(changeset, field, fn _, value ->
      case URI.parse(value) do
        %URI{scheme: scheme} when scheme in ["http", "https"] -> []
        _ -> [{field, "有効なURLを入力してください"}]
      end
    end)
  end

  @doc """
  利用可能なコードタイプのリスト。
  """
  def code_types, do: @code_types

  @doc """
  コードタイプの日本語ラベル。
  """
  def code_type_label(type) do
    case type do
      "ticket" -> "チケット"
      "location" -> "会場案内"
      "vendor" -> "出店者"
      "info" -> "一般情報"
      "custom" -> "カスタム"
      _ -> type
    end
  end
end
