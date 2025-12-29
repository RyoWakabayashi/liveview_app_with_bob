defmodule ElixirPlayground.Learning.UserProgress do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_progress" do
    field :completed, :boolean, default: false
    field :last_code, :string
    field :attempts, :integer, default: 0
    field :completed_at, :utc_datetime

    belongs_to :user, ElixirPlayground.Accounts.User
    belongs_to :exercise, ElixirPlayground.Learning.Exercise

    timestamps()
  end

  @doc false
  def changeset(user_progress, attrs) do
    user_progress
    |> cast(attrs, [:user_id, :exercise_id, :completed, :last_code, :attempts, :completed_at])
    |> validate_required([:user_id, :exercise_id])
    |> validate_number(:attempts, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:exercise_id)
    |> unique_constraint([:user_id, :exercise_id])
  end

  @doc """
  Marks the progress as completed and sets the completion timestamp.
  """
  def mark_completed(user_progress) do
    user_progress
    |> change(%{completed: true, completed_at: DateTime.utc_now() |> DateTime.truncate(:second)})
  end

  @doc """
  Increments the attempts counter.
  """
  def increment_attempts(changeset) do
    # Get the current attempts value from the changeset's data
    current_attempts = Ecto.Changeset.get_field(changeset, :attempts)

    changeset
    |> Ecto.Changeset.put_change(:attempts, current_attempts + 1)
  end
end
