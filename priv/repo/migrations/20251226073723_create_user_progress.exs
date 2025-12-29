defmodule ElixirPlayground.Repo.Migrations.CreateUserProgress do
  use Ecto.Migration

  def change do
    create table(:user_progress) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :exercise_id, references(:exercises, on_delete: :delete_all), null: false
      add :completed, :boolean, default: false, null: false
      add :last_code, :text
      add :attempts, :integer, default: 0, null: false
      add :completed_at, :utc_datetime

      timestamps()
    end

    create index(:user_progress, [:user_id])
    create index(:user_progress, [:exercise_id])
    create unique_index(:user_progress, [:user_id, :exercise_id])
  end
end
