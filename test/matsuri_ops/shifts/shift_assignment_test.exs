defmodule MatsuriOps.Shifts.ShiftAssignmentTest do
  use MatsuriOps.DataCase, async: true

  alias MatsuriOps.Shifts.ShiftAssignment

  describe "changeset/2" do
    test "valid changeset with required fields" do
      changeset = ShiftAssignment.changeset(%ShiftAssignment{}, %{
        shift_id: 1,
        user_id: 1
      })

      assert changeset.valid?
    end

    test "invalid changeset without shift_id" do
      changeset = ShiftAssignment.changeset(%ShiftAssignment{}, %{user_id: 1})
      refute changeset.valid?
      assert %{shift_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid changeset without user_id" do
      changeset = ShiftAssignment.changeset(%ShiftAssignment{}, %{shift_id: 1})
      refute changeset.valid?
      assert %{user_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid changeset with invalid status" do
      changeset = ShiftAssignment.changeset(%ShiftAssignment{}, %{
        shift_id: 1,
        user_id: 1,
        status: "invalid"
      })

      refute changeset.valid?
      assert %{status: ["is invalid"]} = errors_on(changeset)
    end

    test "valid changeset with all fields" do
      changeset = ShiftAssignment.changeset(%ShiftAssignment{}, %{
        shift_id: 1,
        user_id: 1,
        status: "confirmed",
        notes: "メモ"
      })

      assert changeset.valid?
    end
  end

  describe "statuses/0" do
    test "returns all valid statuses" do
      statuses = ShiftAssignment.statuses()
      assert "assigned" in statuses
      assert "confirmed" in statuses
      assert "declined" in statuses
    end
  end
end
