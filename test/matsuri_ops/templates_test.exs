defmodule MatsuriOps.TemplatesTest do
  @moduledoc """
  テンプレート管理機能のテスト。

  TDDフェーズ: 🔴 RED
  - T-TPL-001: Templateスキーマテスト
  - T-TPL-002: テンプレート作成機能テスト
  - T-TPL-003: テンプレートから祭り作成テスト
  """

  use MatsuriOps.DataCase

  alias MatsuriOps.Templates
  alias MatsuriOps.Templates.Template

  import MatsuriOps.AccountsFixtures

  describe "Template schema" do
    test "changeset with valid attributes" do
      user = user_fixture()

      valid_attrs = %{
        name: "玄蕃まつりテンプレート",
        description: "玄蕃まつりの標準テンプレート",
        scale: "medium",
        default_expected_visitors: 5000,
        default_expected_vendors: 50,
        is_public: true
      }

      changeset = Template.changeset(%Template{creator_id: user.id}, valid_attrs)
      assert changeset.valid?
    end

    test "changeset requires name" do
      changeset = Template.changeset(%Template{}, %{})
      refute changeset.valid?
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "changeset validates scale inclusion" do
      attrs = %{name: "テスト", scale: "invalid"}
      changeset = Template.changeset(%Template{}, attrs)
      refute changeset.valid?
      assert %{scale: ["is invalid"]} = errors_on(changeset)
    end

    test "changeset accepts valid scales" do
      user = user_fixture()

      for scale <- ~w(small medium large) do
        attrs = %{name: "テスト", scale: scale}
        changeset = Template.changeset(%Template{creator_id: user.id}, attrs)
        assert changeset.valid?, "Scale '#{scale}' should be valid"
      end
    end

    test "changeset validates expected_visitors is non-negative" do
      attrs = %{name: "テスト", default_expected_visitors: -100}
      changeset = Template.changeset(%Template{}, attrs)
      refute changeset.valid?
      assert %{default_expected_visitors: ["must be greater than or equal to 0"]} = errors_on(changeset)
    end

    test "changeset validates expected_vendors is non-negative" do
      attrs = %{name: "テスト", default_expected_vendors: -10}
      changeset = Template.changeset(%Template{}, attrs)
      refute changeset.valid?
      assert %{default_expected_vendors: ["must be greater than or equal to 0"]} = errors_on(changeset)
    end

    test "changeset has default values" do
      attrs = %{name: "テスト"}
      changeset = Template.changeset(%Template{}, attrs)
      assert Ecto.Changeset.get_field(changeset, :scale) == "medium"
      assert Ecto.Changeset.get_field(changeset, :is_public) == false
    end
  end

  describe "create_template/2" do
    test "creates a template with valid attributes" do
      user = user_fixture()

      attrs = %{
        name: "新規テンプレート",
        description: "テスト用テンプレート",
        scale: "small"
      }

      assert {:ok, %Template{} = template} = Templates.create_template(user, attrs)
      assert template.name == "新規テンプレート"
      assert template.description == "テスト用テンプレート"
      assert template.scale == "small"
      assert template.creator_id == user.id
    end

    test "returns error changeset with invalid attributes" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Templates.create_template(user, %{})
    end
  end

  describe "get_template!/1" do
    test "returns the template with given id" do
      user = user_fixture()
      {:ok, template} = Templates.create_template(user, %{name: "テスト"})

      fetched = Templates.get_template!(template.id)
      assert fetched.id == template.id
      assert fetched.name == "テスト"
    end

    test "raises when template does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Templates.get_template!(-1)
      end
    end
  end

  describe "list_templates/1" do
    test "returns all templates for a user" do
      user = user_fixture()
      {:ok, template1} = Templates.create_template(user, %{name: "テンプレート1"})
      {:ok, template2} = Templates.create_template(user, %{name: "テンプレート2"})

      templates = Templates.list_templates(user)
      template_ids = Enum.map(templates, & &1.id)

      assert template1.id in template_ids
      assert template2.id in template_ids
    end

    test "returns public templates from other users" do
      user1 = user_fixture()
      user2 = user_fixture()

      {:ok, public_template} = Templates.create_template(user1, %{name: "公開", is_public: true})
      {:ok, private_template} = Templates.create_template(user1, %{name: "非公開", is_public: false})

      templates = Templates.list_templates(user2)
      template_ids = Enum.map(templates, & &1.id)

      assert public_template.id in template_ids
      refute private_template.id in template_ids
    end
  end

  describe "update_template/2" do
    test "updates the template with valid attributes" do
      user = user_fixture()
      {:ok, template} = Templates.create_template(user, %{name: "元の名前"})

      assert {:ok, updated} = Templates.update_template(template, %{name: "新しい名前"})
      assert updated.name == "新しい名前"
    end

    test "returns error changeset with invalid attributes" do
      user = user_fixture()
      {:ok, template} = Templates.create_template(user, %{name: "テスト"})

      assert {:error, %Ecto.Changeset{}} = Templates.update_template(template, %{name: ""})
    end
  end

  describe "delete_template/1" do
    test "deletes the template" do
      user = user_fixture()
      {:ok, template} = Templates.create_template(user, %{name: "削除対象"})

      assert {:ok, %Template{}} = Templates.delete_template(template)

      assert_raise Ecto.NoResultsError, fn ->
        Templates.get_template!(template.id)
      end
    end
  end

  describe "copy_template/2" do
    test "creates a copy of existing template" do
      user = user_fixture()
      {:ok, original} = Templates.create_template(user, %{
        name: "オリジナル",
        description: "説明",
        scale: "large",
        default_expected_visitors: 10000
      })

      assert {:ok, copy} = Templates.copy_template(original, user)
      assert copy.name == "オリジナル (コピー)"
      assert copy.description == "説明"
      assert copy.scale == "large"
      assert copy.default_expected_visitors == 10000
      assert copy.id != original.id
    end
  end

  describe "create_template_from_festival/2" do
    test "creates a template from an existing festival" do
      user = user_fixture()

      # Create a festival with some data
      {:ok, festival} = MatsuriOps.Festivals.create_festival(user, %{
        name: "2025年玄蕃まつり",
        start_date: ~D[2025-08-01],
        end_date: ~D[2025-08-02],
        scale: "medium",
        expected_visitors: 5000,
        expected_vendors: 50
      })

      assert {:ok, template} = Templates.create_template_from_festival(festival, %{name: "玄蕃まつりテンプレート"})
      assert template.name == "玄蕃まつりテンプレート"
      assert template.scale == "medium"
      assert template.default_expected_visitors == 5000
      assert template.default_expected_vendors == 50
    end
  end

  describe "apply_template/3" do
    test "creates a festival from a template" do
      user = user_fixture()
      {:ok, template} = Templates.create_template(user, %{
        name: "祭りテンプレート",
        scale: "medium",
        default_expected_visitors: 5000,
        default_expected_vendors: 50
      })

      festival_attrs = %{
        name: "2026年玄蕃まつり",
        start_date: ~D[2026-08-01],
        end_date: ~D[2026-08-02]
      }

      assert {:ok, festival} = Templates.apply_template(template, user, festival_attrs)
      assert festival.name == "2026年玄蕃まつり"
      assert festival.scale == "medium"
      assert festival.expected_visitors == 5000
      assert festival.expected_vendors == 50
      assert festival.organizer_id == user.id
    end

    test "festival attrs override template defaults" do
      user = user_fixture()
      {:ok, template} = Templates.create_template(user, %{
        name: "テンプレート",
        scale: "medium",
        default_expected_visitors: 5000
      })

      festival_attrs = %{
        name: "大規模祭り",
        start_date: ~D[2026-08-01],
        end_date: ~D[2026-08-02],
        scale: "large",
        expected_visitors: 20000
      }

      assert {:ok, festival} = Templates.apply_template(template, user, festival_attrs)
      assert festival.scale == "large"
      assert festival.expected_visitors == 20000
    end
  end
end
