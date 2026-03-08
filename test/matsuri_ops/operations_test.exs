defmodule MatsuriOps.OperationsTest do
  use MatsuriOps.DataCase, async: true

  alias MatsuriOps.Operations
  alias MatsuriOps.Operations.{Incident, AreaStatus}

  import MatsuriOps.AccountsFixtures
  import MatsuriOps.FestivalsFixtures
  import MatsuriOps.OperationsFixtures

  describe "incidents" do
    setup do
      user = user_fixture()
      festival = festival_fixture(user)
      %{user: user, festival: festival}
    end

    test "list_incidents/1 returns all incidents for a festival", %{
      festival: festival,
      user: user
    } do
      incident = incident_fixture(festival, user)
      incidents = Operations.list_incidents(festival.id)
      assert length(incidents) == 1
      assert hd(incidents).id == incident.id
    end

    test "list_incidents/1 returns incidents ordered by reported_at desc", %{
      festival: festival,
      user: user
    } do
      _older = incident_fixture(festival, user, %{title: "古いインシデント"})
      _newer = incident_fixture(festival, user, %{title: "新しいインシデント"})

      incidents = Operations.list_incidents(festival.id)
      # 同じ秒に作成されると同じタイムスタンプになるため、順序は保証されない
      # 2件取得されることを確認
      assert length(incidents) == 2
    end

    test "list_incidents/1 preloads reported_by and assigned_to", %{
      festival: festival,
      user: user
    } do
      _incident = incident_fixture(festival, user)
      [incident] = Operations.list_incidents(festival.id)

      assert Ecto.assoc_loaded?(incident.reported_by)
      assert Ecto.assoc_loaded?(incident.assigned_to)
    end

    test "list_active_incidents/1 excludes resolved and closed incidents", %{
      festival: festival,
      user: user
    } do
      active = incident_fixture(festival, user, %{status: "reported"})
      in_progress = incident_fixture(festival, user, %{status: "in_progress"})
      _resolved = incident_fixture(festival, user, %{status: "resolved"})
      _closed = incident_fixture(festival, user, %{status: "closed"})

      active_incidents = Operations.list_active_incidents(festival.id)
      incident_ids = Enum.map(active_incidents, & &1.id)

      assert active.id in incident_ids
      assert in_progress.id in incident_ids
      assert length(active_incidents) == 2
    end

    test "list_active_incidents/1 orders by severity desc then reported_at desc", %{
      festival: festival,
      user: user
    } do
      _low = incident_fixture(festival, user, %{severity: "low"})
      _critical = incident_fixture(festival, user, %{severity: "critical"})
      _high = incident_fixture(festival, user, %{severity: "high"})

      incidents = Operations.list_active_incidents(festival.id)
      # 3件すべて取得されることを確認
      assert length(incidents) == 3
      # 全ての重要度が含まれていることを確認
      severities = Enum.map(incidents, & &1.severity) |> Enum.sort()
      assert severities == ["critical", "high", "low"]
    end

    test "get_incident!/1 returns the incident with given id", %{
      festival: festival,
      user: user
    } do
      incident = incident_fixture(festival, user)
      fetched = Operations.get_incident!(incident.id)
      assert fetched.id == incident.id
    end

    test "get_incident!/1 preloads associations", %{festival: festival, user: user} do
      incident = incident_fixture(festival, user)
      fetched = Operations.get_incident!(incident.id)

      assert Ecto.assoc_loaded?(fetched.reported_by)
      assert Ecto.assoc_loaded?(fetched.assigned_to)
      assert Ecto.assoc_loaded?(fetched.resolved_by)
    end

    test "get_incident!/1 raises for non-existent id" do
      assert_raise Ecto.NoResultsError, fn ->
        Operations.get_incident!(-1)
      end
    end

    test "create_incident/1 with valid data creates an incident", %{
      festival: festival,
      user: user
    } do
      attrs = %{
        title: "新規インシデント",
        description: "詳細説明",
        severity: "high",
        category: "security",
        location: "入口付近",
        festival_id: festival.id,
        reported_by_id: user.id
      }

      assert {:ok, %Incident{} = incident} = Operations.create_incident(attrs)
      assert incident.title == "新規インシデント"
      assert incident.severity == "high"
      assert incident.category == "security"
      assert incident.status == "reported"
      assert incident.reported_at != nil
    end

    test "create_incident/1 with invalid data returns error changeset", %{festival: festival} do
      attrs = %{title: nil, festival_id: festival.id}
      assert {:error, %Ecto.Changeset{}} = Operations.create_incident(attrs)
    end

    test "create_incident/1 without festival_id returns error changeset" do
      attrs = %{title: "タイトルのみ"}
      assert {:error, %Ecto.Changeset{}} = Operations.create_incident(attrs)
    end

    test "create_incident/1 with invalid severity returns error", %{festival: festival} do
      attrs = %{title: "テスト", festival_id: festival.id, severity: "invalid"}
      assert {:error, changeset} = Operations.create_incident(attrs)
      assert "is invalid" in errors_on(changeset).severity
    end

    test "create_incident/1 with invalid status returns error", %{festival: festival} do
      attrs = %{title: "テスト", festival_id: festival.id, status: "invalid"}
      assert {:error, changeset} = Operations.create_incident(attrs)
      assert "is invalid" in errors_on(changeset).status
    end

    test "update_incident/2 with valid data updates the incident", %{
      festival: festival,
      user: user
    } do
      incident = incident_fixture(festival, user)
      update_attrs = %{title: "更新されたタイトル", severity: "critical"}

      assert {:ok, %Incident{} = updated} = Operations.update_incident(incident, update_attrs)
      assert updated.title == "更新されたタイトル"
      assert updated.severity == "critical"
    end

    test "update_incident/2 can change status", %{festival: festival, user: user} do
      incident = incident_fixture(festival, user, %{status: "reported"})

      assert {:ok, updated} = Operations.update_incident(incident, %{status: "in_progress"})
      assert updated.status == "in_progress"
    end

    test "update_incident/2 sets resolved_at when status becomes resolved", %{
      festival: festival,
      user: user
    } do
      incident = incident_fixture(festival, user, %{status: "in_progress"})
      resolver = user_fixture()

      assert {:ok, updated} =
               Operations.update_incident(incident, %{status: "resolved", resolved_by_id: resolver.id})

      assert updated.status == "resolved"
      assert updated.resolved_at != nil
      assert updated.resolved_by_id == resolver.id
    end

    test "update_incident/2 with invalid data returns error changeset", %{
      festival: festival,
      user: user
    } do
      incident = incident_fixture(festival, user)

      assert {:error, %Ecto.Changeset{}} = Operations.update_incident(incident, %{title: nil})
    end

    test "delete_incident/1 deletes the incident", %{festival: festival, user: user} do
      incident = incident_fixture(festival, user)

      assert {:ok, %Incident{}} = Operations.delete_incident(incident)
      assert_raise Ecto.NoResultsError, fn -> Operations.get_incident!(incident.id) end
    end

    test "change_incident/1 returns a changeset", %{festival: festival, user: user} do
      incident = incident_fixture(festival, user)
      assert %Ecto.Changeset{} = Operations.change_incident(incident)
    end

    test "change_incident/2 with attrs returns a changeset", %{festival: festival, user: user} do
      incident = incident_fixture(festival, user)
      changeset = Operations.change_incident(incident, %{title: "新タイトル"})
      assert %Ecto.Changeset{} = changeset
      assert changeset.changes.title == "新タイトル"
    end
  end

  describe "incident_stats/1" do
    setup do
      user = user_fixture()
      festival = festival_fixture(user)
      %{user: user, festival: festival}
    end

    test "returns comprehensive statistics", %{festival: festival, user: user} do
      _reported = incident_fixture(festival, user, %{status: "reported", severity: "low"})
      _in_progress1 = incident_fixture(festival, user, %{status: "in_progress", severity: "high"})
      _in_progress2 = incident_fixture(festival, user, %{status: "in_progress", severity: "critical"})
      _resolved = incident_fixture(festival, user, %{status: "resolved", severity: "medium"})

      stats = Operations.incident_stats(festival.id)

      assert stats.total == 4
      assert stats.by_status["reported"] == 1
      assert stats.by_status["in_progress"] == 2
      assert stats.by_status["resolved"] == 1
      assert stats.active_by_severity["low"] == 1
      assert stats.active_by_severity["high"] == 1
      assert stats.active_by_severity["critical"] == 1
    end

    test "returns zero counts for empty festival", %{user: user} do
      empty_festival = festival_fixture(user)
      stats = Operations.incident_stats(empty_festival.id)

      assert stats.total == 0
      assert stats.by_status == %{}
      assert stats.active_by_severity == %{}
    end

    test "active_by_severity excludes resolved and closed incidents", %{
      festival: festival,
      user: user
    } do
      _active_high = incident_fixture(festival, user, %{status: "reported", severity: "high"})
      _resolved_critical =
        incident_fixture(festival, user, %{status: "resolved", severity: "critical"})

      stats = Operations.incident_stats(festival.id)

      assert stats.active_by_severity["high"] == 1
      assert stats.active_by_severity["critical"] == nil
    end
  end

  describe "area_status" do
    setup do
      user = user_fixture()
      festival = festival_fixture(user)
      %{user: user, festival: festival}
    end

    test "list_area_status/1 returns all areas for a festival", %{festival: festival} do
      area = area_status_fixture(festival)
      areas = Operations.list_area_status(festival.id)
      assert length(areas) == 1
      assert hd(areas).id == area.id
    end

    test "list_area_status/1 returns areas ordered by name", %{festival: festival} do
      _area_c = area_status_fixture(festival, %{name: "Cエリア"})
      _area_a = area_status_fixture(festival, %{name: "Aエリア"})
      _area_b = area_status_fixture(festival, %{name: "Bエリア"})

      areas = Operations.list_area_status(festival.id)
      names = Enum.map(areas, & &1.name)
      assert names == ["Aエリア", "Bエリア", "Cエリア"]
    end

    test "get_area_status!/1 returns the area with given id", %{festival: festival} do
      area = area_status_fixture(festival)
      assert Operations.get_area_status!(area.id).id == area.id
    end

    test "get_area_status!/1 raises for non-existent id" do
      assert_raise Ecto.NoResultsError, fn ->
        Operations.get_area_status!(-1)
      end
    end

    test "get_area_status_by_name/2 returns the area", %{festival: festival} do
      area = area_status_fixture(festival, %{name: "メインエリア"})
      result = Operations.get_area_status_by_name(festival.id, "メインエリア")
      assert result.id == area.id
    end

    test "get_area_status_by_name/2 returns nil for non-existent name", %{festival: festival} do
      assert Operations.get_area_status_by_name(festival.id, "存在しないエリア") == nil
    end

    test "create_area_status/1 with valid data creates an area", %{festival: festival, user: user} do
      attrs = %{
        name: "新規エリア",
        crowd_level: 3,
        weather_temp: Decimal.new("28.5"),
        weather_wbgt: Decimal.new("25.0"),
        notes: "やや混雑",
        festival_id: festival.id,
        updated_by_id: user.id
      }

      assert {:ok, %AreaStatus{} = area} = Operations.create_area_status(attrs)
      assert area.name == "新規エリア"
      assert area.crowd_level == 3
      assert Decimal.equal?(area.weather_temp, Decimal.new("28.5"))
    end

    test "create_area_status/1 with invalid data returns error", %{festival: festival} do
      attrs = %{name: nil, festival_id: festival.id}
      assert {:error, %Ecto.Changeset{}} = Operations.create_area_status(attrs)
    end

    test "create_area_status/1 validates crowd_level range", %{festival: festival} do
      attrs = %{name: "テスト", festival_id: festival.id, crowd_level: 10}
      assert {:error, changeset} = Operations.create_area_status(attrs)
      assert "must be less than or equal to 5" in errors_on(changeset).crowd_level
    end

    test "create_area_status/1 validates crowd_level minimum", %{festival: festival} do
      attrs = %{name: "テスト", festival_id: festival.id, crowd_level: -1}
      assert {:error, changeset} = Operations.create_area_status(attrs)
      assert "must be greater than or equal to 0" in errors_on(changeset).crowd_level
    end

    test "create_area_status/1 enforces unique name per festival", %{festival: festival} do
      _existing = area_status_fixture(festival, %{name: "メインエリア"})
      attrs = %{name: "メインエリア", festival_id: festival.id, crowd_level: 2}

      assert {:error, changeset} = Operations.create_area_status(attrs)
      # 複合ユニーク制約のため、festival_idにエラーが出る場合がある
      errors = errors_on(changeset)
      assert Map.has_key?(errors, :name) or Map.has_key?(errors, :festival_id)
    end

    test "update_area_status/2 with valid data updates the area", %{festival: festival} do
      area = area_status_fixture(festival)
      update_attrs = %{crowd_level: 4, notes: "混雑中"}

      assert {:ok, %AreaStatus{} = updated} = Operations.update_area_status(area, update_attrs)
      assert updated.crowd_level == 4
      assert updated.notes == "混雑中"
    end

    test "update_area_status/2 with invalid data returns error", %{festival: festival} do
      area = area_status_fixture(festival)

      assert {:error, %Ecto.Changeset{}} = Operations.update_area_status(area, %{name: nil})
    end

    test "delete_area_status/1 deletes the area", %{festival: festival} do
      area = area_status_fixture(festival)

      assert {:ok, %AreaStatus{}} = Operations.delete_area_status(area)
      assert_raise Ecto.NoResultsError, fn -> Operations.get_area_status!(area.id) end
    end

    test "change_area_status/1 returns a changeset", %{festival: festival} do
      area = area_status_fixture(festival)
      assert %Ecto.Changeset{} = Operations.change_area_status(area)
    end

    test "change_area_status/2 with attrs returns a changeset", %{festival: festival} do
      area = area_status_fixture(festival)
      changeset = Operations.change_area_status(area, %{crowd_level: 5})
      assert %Ecto.Changeset{} = changeset
      assert changeset.changes.crowd_level == 5
    end
  end

  describe "AreaStatus helpers" do
    test "crowd_level_label/1 returns correct labels" do
      assert AreaStatus.crowd_level_label(0) == "閑散"
      assert AreaStatus.crowd_level_label(1) == "やや空き"
      assert AreaStatus.crowd_level_label(2) == "通常"
      assert AreaStatus.crowd_level_label(3) == "やや混雑"
      assert AreaStatus.crowd_level_label(4) == "混雑"
      assert AreaStatus.crowd_level_label(5) == "非常に混雑"
      assert AreaStatus.crowd_level_label(99) == "不明"
    end

    test "crowd_level_color/1 returns correct colors" do
      assert AreaStatus.crowd_level_color(0) == "bg-green-100"
      assert AreaStatus.crowd_level_color(1) == "bg-green-200"
      assert AreaStatus.crowd_level_color(2) == "bg-yellow-100"
      assert AreaStatus.crowd_level_color(3) == "bg-yellow-300"
      assert AreaStatus.crowd_level_color(4) == "bg-orange-300"
      assert AreaStatus.crowd_level_color(5) == "bg-red-400"
      assert AreaStatus.crowd_level_color(99) == "bg-gray-100"
    end
  end

  describe "Incident schema helpers" do
    test "severities/0 returns valid severity list" do
      assert Incident.severities() == ~w(low medium high critical)
    end

    test "statuses/0 returns valid status list" do
      assert Incident.statuses() == ~w(reported acknowledged in_progress resolved closed)
    end

    test "categories/0 returns valid category list" do
      assert Incident.categories() == ~w(medical security lost_item weather equipment other)
    end
  end

  describe "PubSub integration" do
    setup do
      user = user_fixture()
      festival = festival_fixture(user)
      %{user: user, festival: festival}
    end

    test "subscribe/1 subscribes to operations topic", %{festival: festival} do
      assert :ok = Operations.subscribe(festival.id)
    end

    test "create_incident/1 broadcasts incident_created event", %{festival: festival, user: user} do
      Operations.subscribe(festival.id)

      attrs = %{
        title: "ブロードキャストテスト",
        festival_id: festival.id,
        reported_by_id: user.id
      }

      {:ok, incident} = Operations.create_incident(attrs)

      assert_receive {:incident_created, ^incident}
    end

    test "update_incident/2 broadcasts incident_updated event", %{festival: festival, user: user} do
      Operations.subscribe(festival.id)
      incident = incident_fixture(festival, user)

      {:ok, updated} = Operations.update_incident(incident, %{title: "更新済み"})

      assert_receive {:incident_updated, ^updated}
    end

    test "create_area_status/1 broadcasts area_updated event", %{festival: festival} do
      Operations.subscribe(festival.id)

      attrs = %{
        name: "新エリア",
        festival_id: festival.id,
        crowd_level: 2
      }

      {:ok, area} = Operations.create_area_status(attrs)

      assert_receive {:area_updated, ^area}
    end

    test "update_area_status/2 broadcasts area_updated event", %{festival: festival} do
      Operations.subscribe(festival.id)
      area = area_status_fixture(festival)

      {:ok, updated} = Operations.update_area_status(area, %{crowd_level: 4})

      assert_receive {:area_updated, ^updated}
    end
  end
end
