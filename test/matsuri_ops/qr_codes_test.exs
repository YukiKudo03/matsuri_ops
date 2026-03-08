defmodule MatsuriOps.QRCodesTest do
  use MatsuriOps.DataCase

  alias MatsuriOps.QRCodes
  alias MatsuriOps.QRCodes.QRCode

  describe "qr_codes" do
    setup do
      festival = festival_fixture()
      %{festival: festival}
    end

    @valid_attrs %{
      name: "テストQRコード",
      code_type: "ticket",
      target_url: "https://example.com/ticket/123"
    }
    @update_attrs %{
      name: "更新されたQRコード",
      code_type: "location",
      target_url: "https://example.com/location/456"
    }
    @invalid_attrs %{name: nil, code_type: nil, target_url: nil}

    def qr_code_fixture(festival, attrs \\ %{}) do
      {:ok, qr_code} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.put(:festival_id, festival.id)
        |> QRCodes.create_qr_code()

      qr_code
    end

    test "list_qr_codes/1 returns all qr_codes for a festival", %{festival: festival} do
      qr_code = qr_code_fixture(festival)
      assert QRCodes.list_qr_codes(festival.id) == [qr_code]
    end

    test "list_qr_codes/1 returns empty list for festival with no qr_codes", %{festival: _festival} do
      other_festival = festival_fixture(%{name: "別の祭り"})
      assert QRCodes.list_qr_codes(other_festival.id) == []
    end

    test "list_qr_codes_by_type/2 filters by code_type", %{festival: festival} do
      qr_code_fixture(festival, %{code_type: "ticket"})
      qr_code_fixture(festival, %{name: "別のQR", code_type: "location", target_url: "https://example.com/loc"})

      ticket_codes = QRCodes.list_qr_codes_by_type(festival.id, "ticket")
      assert length(ticket_codes) == 1
      assert hd(ticket_codes).code_type == "ticket"
    end

    test "get_qr_code!/1 returns the qr_code with given id", %{festival: festival} do
      qr_code = qr_code_fixture(festival)
      assert QRCodes.get_qr_code!(qr_code.id) == qr_code
    end

    test "get_qr_code/1 returns nil for non-existent id" do
      assert QRCodes.get_qr_code(999_999) == nil
    end

    test "create_qr_code/1 with valid data creates a qr_code and generates SVG", %{festival: festival} do
      attrs = Map.put(@valid_attrs, :festival_id, festival.id)
      assert {:ok, %QRCode{} = qr_code} = QRCodes.create_qr_code(attrs)
      assert qr_code.name == "テストQRコード"
      assert qr_code.code_type == "ticket"
      assert qr_code.target_url == "https://example.com/ticket/123"
      assert qr_code.svg_data != nil
      assert String.contains?(qr_code.svg_data, "<svg")
    end

    test "create_qr_code/1 with invalid data returns error changeset", %{festival: festival} do
      attrs = Map.put(@invalid_attrs, :festival_id, festival.id)
      assert {:error, %Ecto.Changeset{}} = QRCodes.create_qr_code(attrs)
    end

    test "create_qr_code/1 with invalid URL returns error changeset", %{festival: festival} do
      attrs =
        @valid_attrs
        |> Map.put(:festival_id, festival.id)
        |> Map.put(:target_url, "not-a-url")

      assert {:error, %Ecto.Changeset{} = changeset} = QRCodes.create_qr_code(attrs)
      assert %{target_url: ["有効なURLを入力してください"]} = errors_on(changeset)
    end

    test "create_qr_code/1 with invalid code_type returns error changeset", %{festival: festival} do
      attrs =
        @valid_attrs
        |> Map.put(:festival_id, festival.id)
        |> Map.put(:code_type, "invalid_type")

      assert {:error, %Ecto.Changeset{} = changeset} = QRCodes.create_qr_code(attrs)
      assert %{code_type: ["is invalid"]} = errors_on(changeset)
    end

    test "update_qr_code/2 with valid data updates the qr_code", %{festival: festival} do
      qr_code = qr_code_fixture(festival)
      assert {:ok, %QRCode{} = updated} = QRCodes.update_qr_code(qr_code, @update_attrs)
      assert updated.name == "更新されたQRコード"
      assert updated.code_type == "location"
      assert updated.target_url == "https://example.com/location/456"
    end

    test "update_qr_code/2 regenerates SVG when URL changes", %{festival: festival} do
      qr_code = qr_code_fixture(festival)
      original_svg = qr_code.svg_data

      {:ok, updated} = QRCodes.update_qr_code(qr_code, %{target_url: "https://example.com/new"})

      assert updated.svg_data != original_svg
    end

    test "update_qr_code/2 with invalid data returns error changeset", %{festival: festival} do
      qr_code = qr_code_fixture(festival)
      assert {:error, %Ecto.Changeset{}} = QRCodes.update_qr_code(qr_code, @invalid_attrs)
      assert qr_code == QRCodes.get_qr_code!(qr_code.id)
    end

    test "delete_qr_code/1 deletes the qr_code", %{festival: festival} do
      qr_code = qr_code_fixture(festival)
      assert {:ok, %QRCode{}} = QRCodes.delete_qr_code(qr_code)
      assert_raise Ecto.NoResultsError, fn -> QRCodes.get_qr_code!(qr_code.id) end
    end

    test "change_qr_code/1 returns a qr_code changeset", %{festival: festival} do
      qr_code = qr_code_fixture(festival)
      assert %Ecto.Changeset{} = QRCodes.change_qr_code(qr_code)
    end

    test "increment_scan_count/1 increments the scan count", %{festival: festival} do
      qr_code = qr_code_fixture(festival)
      assert qr_code.scan_count == 0

      {:ok, updated} = QRCodes.increment_scan_count(qr_code)
      assert updated.scan_count == 1

      {:ok, updated2} = QRCodes.increment_scan_count(updated)
      assert updated2.scan_count == 2
    end

    test "increment_scan_count/1 with id increments the scan count", %{festival: festival} do
      qr_code = qr_code_fixture(festival)
      {:ok, updated} = QRCodes.increment_scan_count(qr_code.id)
      assert updated.scan_count == 1
    end

    test "increment_scan_count/1 with invalid id returns error", %{festival: _festival} do
      assert {:error, :not_found} = QRCodes.increment_scan_count(999_999)
    end

    test "get_statistics/1 returns statistics for a festival", %{festival: festival} do
      qr_code_fixture(festival, %{code_type: "ticket"})
      qr_code_fixture(festival, %{name: "QR2", code_type: "ticket", target_url: "https://example.com/2"})
      qr_code_fixture(festival, %{name: "QR3", code_type: "location", target_url: "https://example.com/3"})

      stats = QRCodes.get_statistics(festival.id)
      assert stats.total_count == 3
      assert stats.total_scans == 0
      assert stats.by_type["ticket"] == 2
      assert stats.by_type["location"] == 1
    end

    test "generate_qr_svg/1 generates valid SVG", %{festival: _festival} do
      svg = QRCodes.generate_qr_svg("https://example.com")
      assert String.contains?(svg, "<svg")
      assert String.contains?(svg, "</svg>")
    end

    test "generate_qr_svg/1 with nil returns nil", %{festival: _festival} do
      assert QRCodes.generate_qr_svg(nil) == nil
    end
  end

  defp festival_fixture(attrs \\ %{}) do
    {:ok, festival} =
      attrs
      |> Enum.into(%{
        name: "テスト祭り #{System.unique_integer()}",
        start_date: ~D[2026-08-15],
        end_date: ~D[2026-08-16],
        status: "planning"
      })
      |> MatsuriOps.Festivals.create_festival()

    festival
  end
end
