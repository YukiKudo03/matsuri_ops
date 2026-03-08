defmodule MatsuriOps.ErrorTest do
  @moduledoc """
  エラーハンドリングモジュールのテスト。
  """

  use ExUnit.Case, async: true

  alias MatsuriOps.Error

  describe "handle_error/2" do
    test "handles Ecto.NoResultsError" do
      error = %Ecto.NoResultsError{message: "no results"}
      assert {:error, :not_found, msg} = Error.handle_error(error)
      assert msg =~ "見つかりません"
    end

    test "handles Ecto.Changeset errors" do
      changeset = %Ecto.Changeset{
        errors: [name: {"は必須です", [validation: :required]}],
        valid?: false
      }

      assert {:error, :validation, errors} = Error.handle_error(changeset)
      assert is_map(errors)
    end

    test "handles {:error, atom} tuples" do
      assert {:error, :not_found, msg} = Error.handle_error({:error, :not_found})
      assert msg =~ "見つかりません"
    end

    test "handles {:error, string} tuples" do
      assert {:error, :internal, "カスタムエラー"} = Error.handle_error({:error, "カスタムエラー"})
    end

    test "handles unknown errors" do
      assert {:error, :internal, msg} = Error.handle_error("unknown error")
      assert msg =~ "予期しないエラー"
    end
  end

  describe "format_changeset_errors/1" do
    test "formats changeset errors with interpolation" do
      changeset = %Ecto.Changeset{
        errors: [
          name: {"は%{count}文字以上である必要があります", [count: 3, validation: :length, min: 3]}
        ],
        valid?: false
      }

      errors = Error.format_changeset_errors(changeset)
      assert %{name: [msg]} = errors
      assert msg =~ "3"
    end
  end

  describe "wrap_error/2" do
    test "wraps successful function" do
      assert {:ok, 42} = Error.wrap_error(fn -> {:ok, 42} end)
    end

    test "wraps plain return value" do
      assert {:ok, 42} = Error.wrap_error(fn -> 42 end)
    end

    test "wraps error tuple" do
      assert {:error, :not_found, _} = Error.wrap_error(fn -> {:error, :not_found} end)
    end

    test "catches exceptions" do
      assert {:error, :internal, _} = Error.wrap_error(fn -> raise "boom" end)
    end
  end
end
