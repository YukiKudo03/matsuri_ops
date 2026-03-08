defmodule MatsuriOps.Templates do
  @moduledoc """
  テンプレート管理コンテキスト。

  祭り運営のテンプレートを管理する機能を提供する。
  テンプレートは祭りの雛形として使用でき、予め設定された
  デフォルト値を持つ新しい祭りを効率的に作成できる。
  """

  import Ecto.Query, warn: false
  alias MatsuriOps.Repo
  alias MatsuriOps.Templates.Template
  alias MatsuriOps.Accounts.User
  alias MatsuriOps.Festivals
  alias MatsuriOps.Festivals.Festival

  @doc """
  テンプレートを作成する。

  ## Examples

      iex> create_template(user, %{name: "新規テンプレート"})
      {:ok, %Template{}}

      iex> create_template(user, %{})
      {:error, %Ecto.Changeset{}}

  """
  def create_template(%User{} = user, attrs) do
    %Template{creator_id: user.id}
    |> Template.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  テンプレートを取得する。

  ## Examples

      iex> get_template!(123)
      %Template{}

      iex> get_template!(-1)
      ** (Ecto.NoResultsError)

  """
  def get_template!(id) do
    Repo.get!(Template, id)
  end

  @doc """
  ユーザーがアクセス可能なテンプレートを一覧取得する。

  - ユーザー自身が作成したテンプレート
  - 公開されているテンプレート

  ## Examples

      iex> list_templates(user)
      [%Template{}, ...]

  """
  def list_templates(%User{} = user) do
    Template
    |> where([t], t.creator_id == ^user.id or t.is_public == true)
    |> order_by([t], desc: t.updated_at)
    |> Repo.all()
  end

  @doc """
  テンプレートを更新する。

  ## Examples

      iex> update_template(template, %{name: "新しい名前"})
      {:ok, %Template{}}

      iex> update_template(template, %{name: ""})
      {:error, %Ecto.Changeset{}}

  """
  def update_template(%Template{} = template, attrs) do
    template
    |> Template.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  テンプレートを削除する。

  ## Examples

      iex> delete_template(template)
      {:ok, %Template{}}

  """
  def delete_template(%Template{} = template) do
    Repo.delete(template)
  end

  @doc """
  テンプレートをコピーする。

  ## Examples

      iex> copy_template(original_template, user)
      {:ok, %Template{}}

  """
  def copy_template(%Template{} = original, %User{} = user) do
    attrs = %{
      name: "#{original.name} (コピー)",
      description: original.description,
      scale: original.scale,
      default_expected_visitors: original.default_expected_visitors,
      default_expected_vendors: original.default_expected_vendors,
      is_public: false
    }

    create_template(user, attrs)
  end

  @doc """
  既存の祭りからテンプレートを作成する。

  ## Examples

      iex> create_template_from_festival(festival, %{name: "テンプレート名"})
      {:ok, %Template{}}

  """
  def create_template_from_festival(%Festival{} = festival, attrs) do
    festival = Repo.preload(festival, [:organizer])

    base_attrs = %{
      scale: festival.scale,
      default_expected_visitors: festival.expected_visitors,
      default_expected_vendors: festival.expected_vendors
    }

    merged_attrs = Map.merge(base_attrs, attrs)

    %Template{creator_id: festival.organizer_id}
    |> Template.changeset(merged_attrs)
    |> Repo.insert()
  end

  @doc """
  テンプレートを適用して新しい祭りを作成する。

  テンプレートのデフォルト値を使用するが、festival_attrsで上書き可能。

  ## Examples

      iex> apply_template(template, user, %{name: "新規祭り", start_date: ~D[2026-08-01], end_date: ~D[2026-08-02]})
      {:ok, %Festival{}}

  """
  def apply_template(%Template{} = template, %User{} = user, festival_attrs) do
    # キーを文字列に統一
    string_attrs = stringify_keys(festival_attrs)

    # テンプレートのデフォルト値
    template_defaults = %{
      "scale" => template.scale,
      "expected_visitors" => template.default_expected_visitors,
      "expected_vendors" => template.default_expected_vendors
    }

    # テンプレートのデフォルト値をベースに、festival_attrsで上書き
    # 空文字列や nil は除外してテンプレートのデフォルト値を使用
    merged_attrs =
      template_defaults
      |> Map.merge(string_attrs, fn _key, template_val, user_val ->
        if user_val in ["", nil], do: template_val, else: user_val
      end)
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Map.new()

    Festivals.create_festival(user, merged_attrs)
  end

  defp stringify_keys(map) when is_map(map) do
    Map.new(map, fn
      {k, v} when is_atom(k) -> {Atom.to_string(k), v}
      {k, v} -> {k, v}
    end)
  end

  @doc """
  テンプレート変更用のchangesetを返す。

  ## Examples

      iex> change_template(template, %{name: "新しい名前"})
      %Ecto.Changeset{}

  """
  def change_template(%Template{} = template, attrs \\ %{}) do
    Template.changeset(template, attrs)
  end
end
