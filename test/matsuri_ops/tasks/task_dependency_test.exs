defmodule MatsuriOps.Tasks.TaskDependencyTest do
  use MatsuriOps.DataCase, async: true

  alias MatsuriOps.Tasks.TaskDependency

  describe "changeset/2" do
    test "valid changeset with required fields" do
      changeset = TaskDependency.changeset(%TaskDependency{}, %{
        predecessor_id: 1,
        successor_id: 2
      })

      assert changeset.valid?
    end

    test "invalid changeset without predecessor_id" do
      changeset = TaskDependency.changeset(%TaskDependency{}, %{successor_id: 2})
      refute changeset.valid?
      assert %{predecessor_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid changeset without successor_id" do
      changeset = TaskDependency.changeset(%TaskDependency{}, %{predecessor_id: 1})
      refute changeset.valid?
      assert %{successor_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid changeset with invalid dependency_type" do
      changeset = TaskDependency.changeset(%TaskDependency{}, %{
        predecessor_id: 1,
        successor_id: 2,
        dependency_type: "invalid"
      })

      refute changeset.valid?
      assert %{dependency_type: ["is invalid"]} = errors_on(changeset)
    end

    test "invalid changeset with self-referential dependency" do
      changeset = TaskDependency.changeset(%TaskDependency{}, %{
        predecessor_id: 1,
        successor_id: 1
      })

      refute changeset.valid?
      assert %{successor_id: ["cannot depend on itself"]} = errors_on(changeset)
    end

    test "valid changeset with all dependency types" do
      for type <- TaskDependency.dependency_types() do
        changeset = TaskDependency.changeset(%TaskDependency{}, %{
          predecessor_id: 1,
          successor_id: 2,
          dependency_type: type
        })

        assert changeset.valid?, "Expected #{type} to be valid"
      end
    end
  end

  describe "dependency_types/0" do
    test "returns all valid dependency types" do
      types = TaskDependency.dependency_types()
      assert "finish_to_start" in types
      assert "start_to_start" in types
      assert "finish_to_finish" in types
      assert "start_to_finish" in types
    end
  end
end
