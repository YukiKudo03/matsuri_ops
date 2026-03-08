defmodule MatsuriOps.ShiftsTest do
  @moduledoc """
  シフト管理機能のテスト。

  TDDフェーズ: 🔴 RED → 🟢 GREEN
  """

  use MatsuriOps.DataCase

  alias MatsuriOps.Shifts
  alias MatsuriOps.Shifts.{Shift, ShiftAssignment}
  alias MatsuriOps.Festivals

  import MatsuriOps.AccountsFixtures

  defp create_festival(user) do
    {:ok, festival} =
      Festivals.create_festival(user, %{
        name: "テスト祭り",
        start_date: Date.new!(2025, 8, 1),
        end_date: Date.new!(2025, 8, 2),
        scale: "medium",
        status: "planning"
      })

    festival
  end

  describe "shifts" do
    setup do
      user = user_fixture()
      festival = create_festival(user)
      %{user: user, festival: festival}
    end

    @valid_attrs %{
      name: "朝シフト",
      start_time: ~U[2025-08-01 09:00:00Z],
      end_time: ~U[2025-08-01 13:00:00Z],
      location: "正門",
      required_staff: 3
    }

    @invalid_attrs %{name: nil, start_time: nil, end_time: nil}

    test "list_shifts/1 returns all shifts for a festival", %{festival: festival} do
      shift = shift_fixture(festival)
      [listed_shift] = Shifts.list_shifts(festival.id)
      assert listed_shift.id == shift.id
      assert listed_shift.name == shift.name
    end

    test "get_shift!/1 returns the shift with given id", %{festival: festival} do
      shift = shift_fixture(festival)
      assert Shifts.get_shift!(shift.id) == shift
    end

    test "create_shift/1 with valid data creates a shift", %{festival: festival} do
      attrs = Map.put(@valid_attrs, :festival_id, festival.id)
      assert {:ok, %Shift{} = shift} = Shifts.create_shift(attrs)
      assert shift.name == "朝シフト"
      assert shift.required_staff == 3
    end

    test "create_shift/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Shifts.create_shift(@invalid_attrs)
    end

    test "create_shift/1 validates end_time is after start_time", %{festival: festival} do
      attrs = %{
        name: "無効なシフト",
        start_time: ~U[2025-08-01 13:00:00Z],
        end_time: ~U[2025-08-01 09:00:00Z],
        festival_id: festival.id
      }

      assert {:error, changeset} = Shifts.create_shift(attrs)
      assert "は開始時間より後である必要があります" in errors_on(changeset).end_time
    end

    test "update_shift/2 with valid data updates the shift", %{festival: festival} do
      shift = shift_fixture(festival)
      update_attrs = %{name: "午後シフト"}
      assert {:ok, %Shift{} = shift} = Shifts.update_shift(shift, update_attrs)
      assert shift.name == "午後シフト"
    end

    test "delete_shift/1 deletes the shift", %{festival: festival} do
      shift = shift_fixture(festival)
      assert {:ok, %Shift{}} = Shifts.delete_shift(shift)
      assert_raise Ecto.NoResultsError, fn -> Shifts.get_shift!(shift.id) end
    end
  end

  describe "shift assignments" do
    setup do
      user = user_fixture()
      staff = user_fixture()
      festival = create_festival(user)
      shift = shift_fixture(festival)
      %{user: user, staff: staff, festival: festival, shift: shift}
    end

    test "assign_staff_to_shift/2 assigns a staff member to a shift", %{shift: shift, staff: staff} do
      assert {:ok, %ShiftAssignment{}} = Shifts.assign_staff_to_shift(shift.id, staff.id)

      assignments = Shifts.list_shift_assignments(shift.id)
      assert length(assignments) == 1
      assert hd(assignments).user_id == staff.id
    end

    test "assign_staff_to_shift/2 prevents duplicate assignment", %{shift: shift, staff: staff} do
      {:ok, _} = Shifts.assign_staff_to_shift(shift.id, staff.id)
      assert {:error, _} = Shifts.assign_staff_to_shift(shift.id, staff.id)
    end

    test "unassign_staff_from_shift/2 removes a staff member from a shift", %{shift: shift, staff: staff} do
      {:ok, _} = Shifts.assign_staff_to_shift(shift.id, staff.id)
      assert {:ok, _} = Shifts.unassign_staff_from_shift(shift.id, staff.id)

      assignments = Shifts.list_shift_assignments(shift.id)
      assert assignments == []
    end

    test "check_shift_overlap/3 detects overlapping shifts", %{festival: festival, staff: staff} do
      shift1 = shift_fixture(festival, %{
        start_time: ~U[2025-08-01 09:00:00Z],
        end_time: ~U[2025-08-01 13:00:00Z]
      })
      shift2 = shift_fixture(festival, %{
        start_time: ~U[2025-08-01 11:00:00Z],
        end_time: ~U[2025-08-01 15:00:00Z]
      })

      {:ok, _} = Shifts.assign_staff_to_shift(shift1.id, staff.id)

      assert {:error, :overlap} = Shifts.check_shift_overlap(shift2.id, staff.id, festival.id)
    end

    test "check_shift_overlap/3 allows non-overlapping shifts", %{festival: festival, staff: staff} do
      shift1 = shift_fixture(festival, %{
        start_time: ~U[2025-08-01 09:00:00Z],
        end_time: ~U[2025-08-01 13:00:00Z]
      })
      shift2 = shift_fixture(festival, %{
        start_time: ~U[2025-08-01 14:00:00Z],
        end_time: ~U[2025-08-01 18:00:00Z]
      })

      {:ok, _} = Shifts.assign_staff_to_shift(shift1.id, staff.id)

      assert :ok = Shifts.check_shift_overlap(shift2.id, staff.id, festival.id)
    end
  end

  # Helper functions
  defp shift_fixture(festival, attrs \\ %{}) do
    {:ok, shift} =
      attrs
      |> Enum.into(%{
        name: "テストシフト#{System.unique_integer()}",
        start_time: ~U[2025-08-01 09:00:00Z],
        end_time: ~U[2025-08-01 13:00:00Z],
        location: "テスト場所",
        required_staff: 2,
        festival_id: festival.id
      })
      |> Shifts.create_shift()

    shift
  end
end
