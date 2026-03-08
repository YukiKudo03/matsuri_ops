defmodule MatsuriOps.QRCodes do
  @moduledoc """
  QRコード管理コンテキスト。

  QRコードの生成、管理、スキャン追跡を提供する。
  """

  import Ecto.Query, warn: false
  alias MatsuriOps.Repo
  alias MatsuriOps.QRCodes.QRCode, as: QRCodeSchema

  @doc """
  祭りに関連するQRコード一覧を取得する。

  ## Examples

      iex> list_qr_codes(festival_id)
      [%QRCode{}, ...]
  """
  def list_qr_codes(festival_id) do
    QRCodeSchema
    |> where([q], q.festival_id == ^festival_id)
    |> order_by([q], [desc: q.inserted_at])
    |> Repo.all()
  end

  @doc """
  コードタイプでフィルタしたQRコード一覧を取得する。
  """
  def list_qr_codes_by_type(festival_id, code_type) do
    QRCodeSchema
    |> where([q], q.festival_id == ^festival_id and q.code_type == ^code_type)
    |> order_by([q], [desc: q.inserted_at])
    |> Repo.all()
  end

  @doc """
  QRコードを取得する。

  見つからない場合は`Ecto.NoResultsError`を発生させる。

  ## Examples

      iex> get_qr_code!(123)
      %QRCode{}

      iex> get_qr_code!(456)
      ** (Ecto.NoResultsError)
  """
  def get_qr_code!(id), do: Repo.get!(QRCodeSchema, id)

  @doc """
  QRコードを取得する。見つからない場合はnilを返す。
  """
  def get_qr_code(id), do: Repo.get(QRCodeSchema, id)

  @doc """
  QRコードを作成する。

  SVGデータは自動的に生成される。

  ## Examples

      iex> create_qr_code(%{field: value})
      {:ok, %QRCode{}}

      iex> create_qr_code(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def create_qr_code(attrs \\ %{}) do
    changeset =
      %QRCodeSchema{}
      |> QRCodeSchema.changeset(attrs)

    case changeset do
      %Ecto.Changeset{valid?: true} = changeset ->
        # SVGデータを生成してからインサート
        target_url = Ecto.Changeset.get_change(changeset, :target_url)
        svg_data = generate_qr_svg(target_url)

        changeset
        |> Ecto.Changeset.put_change(:svg_data, svg_data)
        |> Repo.insert()

      invalid_changeset ->
        {:error, invalid_changeset}
    end
  end

  @doc """
  QRコードを更新する。

  target_urlが変更された場合、SVGデータも再生成される。

  ## Examples

      iex> update_qr_code(qr_code, %{field: new_value})
      {:ok, %QRCode{}}

      iex> update_qr_code(qr_code, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def update_qr_code(%QRCodeSchema{} = qr_code, attrs) do
    changeset = QRCodeSchema.changeset(qr_code, attrs)

    # target_urlが変更された場合はSVGを再生成
    changeset =
      if Ecto.Changeset.get_change(changeset, :target_url) do
        new_url = Ecto.Changeset.get_change(changeset, :target_url)
        svg_data = generate_qr_svg(new_url)
        Ecto.Changeset.put_change(changeset, :svg_data, svg_data)
      else
        changeset
      end

    Repo.update(changeset)
  end

  @doc """
  QRコードを削除する。

  ## Examples

      iex> delete_qr_code(qr_code)
      {:ok, %QRCode{}}

      iex> delete_qr_code(qr_code)
      {:error, %Ecto.Changeset{}}
  """
  def delete_qr_code(%QRCodeSchema{} = qr_code) do
    Repo.delete(qr_code)
  end

  @doc """
  QRコードの変更用changesetを返す。
  """
  def change_qr_code(%QRCodeSchema{} = qr_code, attrs \\ %{}) do
    QRCodeSchema.changeset(qr_code, attrs)
  end

  @doc """
  スキャン回数をインクリメントする。
  """
  def increment_scan_count(%QRCodeSchema{} = qr_code) do
    qr_code
    |> QRCodeSchema.increment_scan_changeset()
    |> Repo.update()
  end

  def increment_scan_count(id) when is_integer(id) or is_binary(id) do
    case get_qr_code(id) do
      nil -> {:error, :not_found}
      qr_code -> increment_scan_count(qr_code)
    end
  end

  @doc """
  QRコードのSVGデータを生成する。
  """
  def generate_qr_svg(content) when is_binary(content) do
    case content
         |> QRCode.create(:high)
         |> QRCode.render(:svg) do
      {:ok, svg} -> svg
      {:error, _} -> nil
    end
  end

  def generate_qr_svg(_), do: nil

  @doc """
  QRコードのPNGデータを生成する。
  """
  def generate_qr_png(content) when is_binary(content) do
    content
    |> QRCode.create(:high)
    |> QRCode.render(:png)
  end

  def generate_qr_png(_), do: nil

  @doc """
  祭りのQRコード統計を取得する。
  """
  def get_statistics(festival_id) do
    stats =
      QRCodeSchema
      |> where([q], q.festival_id == ^festival_id)
      |> select([q], %{
        total_count: count(q.id),
        total_scans: sum(q.scan_count)
      })
      |> Repo.one()

    type_stats =
      QRCodeSchema
      |> where([q], q.festival_id == ^festival_id)
      |> group_by([q], q.code_type)
      |> select([q], {q.code_type, count(q.id)})
      |> Repo.all()
      |> Enum.into(%{})

    %{
      total_count: stats.total_count || 0,
      total_scans: stats.total_scans || 0,
      by_type: type_stats
    }
  end
end
