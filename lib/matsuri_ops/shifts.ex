defmodule MatsuriOps.Shifts do
  @moduledoc """
  シフト管理コンテキスト。

  シフトのCRUD操作、スタッフ割り当て、重複チェックを提供する。
  """

  import Ecto.Query, warn: false
  alias MatsuriOps.Repo
  alias MatsuriOps.Shifts.{Shift, ShiftAssignment}

  # Shift functions

  @doc """
  祭りに関連する全てのシフトを取得する。
  """
  def list_shifts(festival_id) do
    Shift
    |> where([s], s.festival_id == ^festival_id)
    |> order_by([s], asc: s.start_time)
    |> Repo.all()
  end

  @doc """
  指定されたIDのシフトを取得する。
  """
  def get_shift!(id), do: Repo.get!(Shift, id)

  @doc """
  シフトを作成する。
  """
  def create_shift(attrs \\ %{}) do
    %Shift{}
    |> Shift.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  シフトを更新する。
  """
  def update_shift(%Shift{} = shift, attrs) do
    shift
    |> Shift.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  シフトを削除する。
  """
  def delete_shift(%Shift{} = shift) do
    Repo.delete(shift)
  end

  @doc """
  シフトのchangesetを返す。
  """
  def change_shift(%Shift{} = shift, attrs \\ %{}) do
    Shift.changeset(shift, attrs)
  end

  # ShiftAssignment functions

  @doc """
  シフトの全ての割り当てを取得する。
  """
  def list_shift_assignments(shift_id) do
    ShiftAssignment
    |> where([a], a.shift_id == ^shift_id)
    |> preload(:user)
    |> Repo.all()
  end

  @doc """
  ユーザーの全ての割り当てを取得する。
  """
  def list_user_assignments(user_id, festival_id) do
    ShiftAssignment
    |> join(:inner, [a], s in Shift, on: a.shift_id == s.id)
    |> where([a, s], a.user_id == ^user_id and s.festival_id == ^festival_id)
    |> preload(:shift)
    |> Repo.all()
  end

  @doc """
  スタッフをシフトに割り当てる。
  """
  def assign_staff_to_shift(shift_id, user_id) do
    %ShiftAssignment{}
    |> ShiftAssignment.changeset(%{shift_id: shift_id, user_id: user_id})
    |> Repo.insert()
  end

  @doc """
  スタッフのシフト割り当てを解除する。
  """
  def unassign_staff_from_shift(shift_id, user_id) do
    case Repo.get_by(ShiftAssignment, shift_id: shift_id, user_id: user_id) do
      nil -> {:error, :not_found}
      assignment -> Repo.delete(assignment)
    end
  end

  @doc """
  シフトの重複をチェックする。

  ユーザーが指定したシフトと重複する既存のシフトに割り当てられているかをチェック。
  """
  def check_shift_overlap(shift_id, user_id, festival_id) do
    shift = get_shift!(shift_id)

    overlapping =
      ShiftAssignment
      |> join(:inner, [a], s in Shift, on: a.shift_id == s.id)
      |> where([a, s], a.user_id == ^user_id)
      |> where([a, s], s.festival_id == ^festival_id)
      |> where([a, s], s.id != ^shift_id)
      |> where([a, s], s.start_time < ^shift.end_time and s.end_time > ^shift.start_time)
      |> Repo.exists?()

    if overlapping, do: {:error, :overlap}, else: :ok
  end

  @doc """
  日付でシフトをグループ化して取得する。
  """
  def list_shifts_by_date(festival_id) do
    list_shifts(festival_id)
    |> Enum.group_by(fn shift ->
      DateTime.to_date(shift.start_time)
    end)
  end
end
