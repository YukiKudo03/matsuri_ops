defmodule MatsuriOps.Repo.Migrations.AddRoleToUsers do
  use Ecto.Migration

  def change do
    # ロール種別: system_admin, executive, admin, leader, staff, volunteer, vendor, visitor
    alter table(:users) do
      add :name, :string
      add :phone, :string
      add :role, :string, default: "volunteer"
      add :organization, :string
      add :emergency_contact, :string
      add :skills, {:array, :string}, default: []
    end

    create index(:users, [:role])
  end
end
