defmodule ElixirPlayground.Learning.Exercise do
  use Ecto.Schema
  import Ecto.Changeset

  schema "exercises" do
    field :title, :string
    field :description, :string
    field :initial_code, :string
    field :solution, :string
    field :expected_output, :string
    field :difficulty, :string, default: "beginner"
    field :order, :integer

    has_many :user_progress, ElixirPlayground.Learning.UserProgress

    timestamps()
  end

  @doc false
  def changeset(exercise, attrs) do
    exercise
    |> cast(attrs, [:title, :description, :initial_code, :solution, :expected_output, :difficulty, :order])
    |> validate_required([:title, :description, :difficulty, :order])
    |> validate_inclusion(:difficulty, ["beginner", "intermediate", "advanced"])
    |> validate_number(:order, greater_than_or_equal_to: 0)
  end
end
