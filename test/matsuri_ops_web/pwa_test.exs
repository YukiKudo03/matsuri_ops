defmodule MatsuriOpsWeb.PWATest do
  @moduledoc """
  PWA機能のテスト。

  TDDフェーズ: 🔴 RED → 🟢 GREEN
  """

  use MatsuriOpsWeb.ConnCase

  describe "manifest.json" do
    test "returns valid JSON manifest", %{conn: conn} do
      conn = get(conn, "/manifest.json")

      assert conn.status == 200
      assert get_resp_header(conn, "content-type") |> hd() =~ "application/json"

      manifest = Jason.decode!(conn.resp_body)
      assert manifest["name"] == "MatsuriOps - 祭り運営支援"
      assert manifest["short_name"] == "MatsuriOps"
      assert manifest["display"] == "standalone"
      assert is_list(manifest["icons"])
    end
  end

  describe "service worker" do
    test "returns service worker script", %{conn: conn} do
      conn = get(conn, "/sw.js")

      assert conn.status == 200
      assert get_resp_header(conn, "content-type") |> hd() =~ "javascript"
      assert conn.resp_body =~ "CACHE_NAME"
    end
  end

  describe "offline page" do
    test "returns offline page", %{conn: conn} do
      conn = get(conn, "/offline.html")

      assert conn.status == 200
      assert get_resp_header(conn, "content-type") |> hd() =~ "text/html"
      assert conn.resp_body =~ "オフライン"
    end
  end
end
