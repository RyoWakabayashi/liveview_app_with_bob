defmodule ElixirPlayground.Learning do
  @moduledoc """
  The Learning context.
  """

  import Ecto.Query, warn: false
  alias ElixirPlayground.Repo

  alias ElixirPlayground.Learning.Exercise
  alias ElixirPlayground.Learning.UserProgress

  @doc """
  Returns the list of exercises ordered by their order field.
  """
  def list_exercises do
    Repo.all(from e in Exercise, order_by: [asc: e.order])
  end

  @doc """
  Returns the list of exercises for a specific difficulty level.
  """
  def list_exercises_by_difficulty(difficulty) do
    Repo.all(from e in Exercise, where: e.difficulty == ^difficulty, order_by: [asc: e.order])
  end

  @doc """
  Gets a single exercise.

  Raises `Ecto.NoResultsError` if the Exercise does not exist.
  """
  def get_exercise!(id), do: Repo.get!(Exercise, id)

  @doc """
  Creates an exercise.
  """
  def create_exercise(attrs \\ %{}) do
    %Exercise{}
    |> Exercise.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an exercise.
  """
  def update_exercise(%Exercise{} = exercise, attrs) do
    exercise
    |> Exercise.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an exercise.
  """
  def delete_exercise(%Exercise{} = exercise) do
    Repo.delete(exercise)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking exercise changes.
  """
  def change_exercise(%Exercise{} = exercise, attrs \\ %{}) do
    Exercise.changeset(exercise, attrs)
  end

  # User Progress functions

  @doc """
  Gets or creates user progress for a specific exercise.
  """
  def get_or_create_progress(user_id, exercise_id) do
    case Repo.get_by(UserProgress, user_id: user_id, exercise_id: exercise_id) do
      nil ->
        %UserProgress{}
        |> UserProgress.changeset(%{user_id: user_id, exercise_id: exercise_id})
        |> Repo.insert()

      progress ->
        {:ok, progress}
    end
  end

  @doc """
  Gets user progress for a specific exercise.
  """
  def get_user_progress(user_id, exercise_id) do
    Repo.get_by(UserProgress, user_id: user_id, exercise_id: exercise_id)
  end

  @doc """
  Lists all progress for a user.
  """
  def list_user_progress(user_id) do
    Repo.all(
      from up in UserProgress,
        where: up.user_id == ^user_id,
        preload: [:exercise],
        order_by: [asc: up.inserted_at]
    )
  end

  @doc """
  Updates user progress with the last code they wrote.
  """
  def update_progress_code(user_id, exercise_id, code) do
    {:ok, progress} = get_or_create_progress(user_id, exercise_id)

    progress
    |> UserProgress.changeset(%{last_code: code})
    |> UserProgress.increment_attempts()
    |> Repo.update()
  end

  @doc """
  Marks an exercise as completed for a user.
  """
  def mark_exercise_completed(user_id, exercise_id) do
    {:ok, progress} = get_or_create_progress(user_id, exercise_id)

    progress
    |> UserProgress.mark_completed()
    |> Repo.update()
  end

  @doc """
  Gets completion statistics for a user.
  """
  def get_user_stats(user_id) do
    total_exercises = Repo.aggregate(Exercise, :count)

    completed_count =
      Repo.one(
        from up in UserProgress,
          where: up.user_id == ^user_id and up.completed == true,
          select: count(up.id)
      )

    %{
      total_exercises: total_exercises,
      completed: completed_count || 0,
      completion_percentage:
        if(total_exercises > 0, do: Float.round(completed_count / total_exercises * 100, 1), else: 0.0)
    }
  end
end
