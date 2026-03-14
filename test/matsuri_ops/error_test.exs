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

    test "handles {:error, changeset} tuples" do
      changeset = %Ecto.Changeset{
        errors: [name: {"は必須です", [validation: :required]}],
        valid?: false
      }

      assert {:error, :validation, errors} = Error.handle_error({:error, changeset})
      assert is_map(errors)
    end

    test "handles {:error, atom} tuples" do
      assert {:error, :not_found, msg} = Error.handle_error({:error, :not_found})
      assert msg =~ "見つかりません"
    end

    test "handles {:error, :unauthorized}" do
      assert {:error, :unauthorized, msg} = Error.handle_error({:error, :unauthorized})
      assert msg =~ "認証"
    end

    test "handles {:error, :forbidden}" do
      assert {:error, :forbidden, msg} = Error.handle_error({:error, :forbidden})
      assert msg =~ "権限"
    end

    test "handles {:error, :conflict}" do
      assert {:error, :conflict, msg} = Error.handle_error({:error, :conflict})
      assert msg =~ "競合"
    end

    test "handles {:error, :timeout}" do
      assert {:error, :timeout, msg} = Error.handle_error({:error, :timeout})
      assert msg =~ "タイムアウト"
    end

    test "handles {:error, :overlap}" do
      assert {:error, :overlap, msg} = Error.handle_error({:error, :overlap})
      assert msg =~ "重複"
    end

    test "handles {:error, unknown_atom}" do
      assert {:error, :custom_error, msg} = Error.handle_error({:error, :custom_error})
      assert msg =~ "custom_error"
    end

    test "handles {:error, string} tuples" do
      assert {:error, :internal, "カスタムエラー"} = Error.handle_error({:error, "カスタムエラー"})
    end

    test "handles unknown errors" do
      assert {:error, :internal, msg} = Error.handle_error("unknown error")
      assert msg =~ "予期しないエラー"
    end

    test "handles error with context" do
      error = %Ecto.NoResultsError{message: "no results"}
      assert {:error, :not_found, _msg} = Error.handle_error(error, %{module: "test"})
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

    test "formats multiple errors" do
      changeset = %Ecto.Changeset{
        errors: [
          name: {"は必須です", [validation: :required]},
          email: {"は有効な形式ではありません", [validation: :format]}
        ],
        valid?: false
      }

      errors = Error.format_changeset_errors(changeset)
      assert Map.has_key?(errors, :name)
      assert Map.has_key?(errors, :email)
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

    test "wraps error with context" do
      assert {:error, :not_found, _} = Error.wrap_error(fn -> {:error, :not_found} end, %{action: "test"})
    end

    test "catches exit signals" do
      result = Error.wrap_error(fn -> exit(:shutdown) end)
      assert {:error, _, _} = result
    end
  end
end
