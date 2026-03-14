defmodule MatsuriOps.Templates.TemplateTest do
  use MatsuriOps.DataCase, async: true

  alias MatsuriOps.Templates.Template

  describe "changeset/2" do
    test "valid changeset with required fields" do
      changeset = Template.changeset(%Template{}, %{name: "テストテンプレート"})
      assert changeset.valid?
    end

    test "invalid changeset without name" do
      changeset = Template.changeset(%Template{}, %{})
      refute changeset.valid?
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid changeset with invalid scale" do
      changeset = Template.changeset(%Template{}, %{name: "テンプレート", scale: "huge"})
      refute changeset.valid?
      assert %{scale: ["is invalid"]} = errors_on(changeset)
    end

    test "invalid changeset with negative expected_visitors" do
      changeset = Template.changeset(%Template{}, %{
        name: "テンプレート",
        default_expected_visitors: -1
      })

      refute changeset.valid?
    end

    test "invalid changeset with negative expected_vendors" do
      changeset = Template.changeset(%Template{}, %{
        name: "テンプレート",
        default_expected_vendors: -1
      })

      refute changeset.valid?
    end

    test "valid changeset with all optional fields" do
      changeset = Template.changeset(%Template{}, %{
        name: "大規模テンプレート",
        description: "大規模祭り用",
        scale: "large",
        default_expected_visitors: 10000,
        default_expected_vendors: 50,
        is_public: true
      })

      assert changeset.valid?
    end
  end

  describe "scales/0" do
    test "returns all valid scales" do
      scales = Template.scales()
      assert "small" in scales
      assert "medium" in scales
      assert "large" in scales
    end
  end
end
