defmodule ElixirPlayground.Repo.Migrations.CreateExercises do
  use Ecto.Migration

  def change do
    create table(:exercises) do
      add :title, :string, null: false
      add :description, :text, null: false
      add :initial_code, :text
      add :solution, :text
      add :expected_output, :text
      add :difficulty, :string, default: "beginner", null: false
      add :order, :integer, null: false

      timestamps()
    end

    create index(:exercises, [:difficulty])
    create index(:exercises, [:order])
  end
end
