defmodule MatsuriOpsWeb.LocationLive.IndexTest do
  use MatsuriOpsWeb.ConnCase

  import Phoenix.LiveViewTest
  import MatsuriOps.AccountsFixtures

  alias MatsuriOps.Festivals
  alias MatsuriOps.Locations

  defp create_festival(user) do
    {:ok, festival} =
      Festivals.create_festival(user, %{
        name: "テスト祭り",
        start_date: Date.new!(2025, 8, 1),
        end_date: Date.new!(2025, 8, 2),
        scale: "medium",
        status: "active"
      })

    festival
  end

  describe "位置マップページ" do
    setup %{conn: conn} do
      user = user_fixture()
      festival = create_festival(user)
      %{conn: log_in_user(conn, user), user: user, festival: festival}
    end

    test "位置マップページを表示できる", %{conn: conn, festival: festival} do
      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/locations")

      assert html =~ "スタッフ位置"
      assert html =~ festival.name
    end

    test "スタッフの位置が表示される", %{conn: conn, festival: festival, user: user} do
      {:ok, _} = Locations.update_staff_location(%{
        user_id: user.id,
        festival_id: festival.id,
        latitude: 36.1234,
        longitude: 138.5678
      })

      {:ok, _view, html} = live(conn, ~p"/festivals/#{festival}/locations")

      assert html =~ user.email
    end

    test "位置を更新できる", %{conn: conn, festival: festival} do
      {:ok, view, _html} = live(conn, ~p"/festivals/#{festival}/locations")

      # 位置更新イベントをシミュレート
      view
      |> render_hook("update_location", %{
        "latitude" => 36.1234,
        "longitude" => 138.5678,
        "accuracy" => 10.0
      })

      html = render(view)
      assert html =~ "36.1234"
    end
  end
end
