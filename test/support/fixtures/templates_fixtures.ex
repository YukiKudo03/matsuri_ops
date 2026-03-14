defmodule MatsuriOps.TemplatesFixtures do
  @moduledoc """
  Test fixtures for Templates context.
  """

  alias MatsuriOps.Templates

  def valid_template_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: "テストテンプレート#{System.unique_integer([:positive])}",
      scale: "medium",
      is_public: false
    })
  end

  def template_fixture(user, attrs \\ %{}) do
    attrs = valid_template_attributes(attrs)

    {:ok, template} = Templates.create_template(user, attrs)
    template
  end
end
