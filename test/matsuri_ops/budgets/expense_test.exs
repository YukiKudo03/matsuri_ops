defmodule MatsuriOps.Budgets.ExpenseTest do
  use MatsuriOps.DataCase, async: true

  alias MatsuriOps.Budgets.Expense

  describe "changeset/2" do
    test "valid changeset with required fields" do
      changeset = Expense.changeset(%Expense{}, %{
        title: "会場費",
        amount: Decimal.new("50000"),
        festival_id: 1
      })

      assert changeset.valid?
    end

    test "invalid changeset without title" do
      changeset = Expense.changeset(%Expense{}, %{amount: Decimal.new("100"), festival_id: 1})
      refute changeset.valid?
      assert %{title: ["can't be blank"]} = errors_on(changeset)
    end

    test "invalid changeset with zero amount" do
      changeset = Expense.changeset(%Expense{}, %{title: "経費", amount: Decimal.new("0"), festival_id: 1})
      refute changeset.valid?
    end

    test "invalid changeset with invalid status" do
      changeset = Expense.changeset(%Expense{}, %{
        title: "経費",
        amount: Decimal.new("100"),
        festival_id: 1,
        status: "invalid"
      })

      refute changeset.valid?
    end

    test "invalid changeset with invalid payment_method" do
      changeset = Expense.changeset(%Expense{}, %{
        title: "経費",
        amount: Decimal.new("100"),
        festival_id: 1,
        payment_method: "bitcoin"
      })

      refute changeset.valid?
    end

    test "valid changeset with all optional fields" do
      changeset = Expense.changeset(%Expense{}, %{
        title: "会場費",
        description: "メイン会場",
        amount: Decimal.new("50000"),
        quantity: 2,
        unit_price: Decimal.new("25000"),
        expense_date: ~D[2026-08-15],
        payment_method: "bank_transfer",
        receipt_number: "E-001",
        status: "submitted",
        notes: "メモ",
        festival_id: 1
      })

      assert changeset.valid?
    end

    test "calculates amount from quantity and unit_price when amount not set" do
      changeset = Expense.changeset(%Expense{}, %{
        title: "備品",
        quantity: 5,
        unit_price: Decimal.new("1000"),
        festival_id: 1
      })

      amount = Ecto.Changeset.get_change(changeset, :amount) || Ecto.Changeset.get_field(changeset, :amount)
      assert amount == Decimal.new("5000")
    end
  end

  describe "approval_changeset/2" do
    test "sets status and approved_at" do
      expense = %Expense{status: "submitted"}
      changeset = Expense.approval_changeset(expense, %{
        status: "approved",
        approved_by_id: 1
      })

      assert Ecto.Changeset.get_change(changeset, :status) == "approved"
      assert Ecto.Changeset.get_change(changeset, :approved_at) != nil
    end

    test "sets approved_at for rejected status" do
      expense = %Expense{status: "submitted"}
      changeset = Expense.approval_changeset(expense, %{status: "rejected"})

      assert Ecto.Changeset.get_change(changeset, :approved_at) != nil
    end
  end

  describe "statuses/0" do
    test "returns all valid statuses" do
      statuses = Expense.statuses()
      assert "pending" in statuses
      assert "submitted" in statuses
      assert "approved" in statuses
      assert "rejected" in statuses
      assert "paid" in statuses
    end
  end

  describe "payment_methods/0" do
    test "returns all valid payment methods" do
      methods = Expense.payment_methods()
      assert "cash" in methods
      assert "bank_transfer" in methods
      assert "credit_card" in methods
      assert "other" in methods
    end
  end
end
