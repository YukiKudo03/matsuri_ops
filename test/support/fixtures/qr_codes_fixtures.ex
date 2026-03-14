defmodule MatsuriOps.QRCodesFixtures do
  @moduledoc """
  Test fixtures for QRCodes context.
  """

  alias MatsuriOps.QRCodes

  def valid_qr_code_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      name: "テストQRコード#{System.unique_integer([:positive])}",
      code_type: "custom",
      target_url: "https://example.com/test"
    })
  end

  def qr_code_fixture(festival, attrs \\ %{}) do
    attrs =
      attrs
      |> valid_qr_code_attributes()
      |> Map.put(:festival_id, festival.id)

    {:ok, qr_code} = QRCodes.create_qr_code(attrs)
    qr_code
  end
end
