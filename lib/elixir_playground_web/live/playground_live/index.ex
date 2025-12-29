defmodule ElixirPlaygroundWeb.PlaygroundLive.Index do
  use ElixirPlaygroundWeb, :live_view

  alias ElixirPlayground.Learning

  @impl true
  def mount(_params, _session, socket) do
    exercises = Learning.list_exercises()
    user_id = socket.assigns.current_scope.user.id
    stats = Learning.get_user_stats(user_id)

    {:ok,
     socket
     |> assign(:exercises, exercises)
     |> assign(:stats, stats)
     |> assign(:page_title, "演習問題一覧")}
  end

  defp extract_first_line(description) do
    description
    |> String.split("\n")
    |> Enum.find(&(String.trim(&1) != ""))
    |> case do
      nil -> ""
      line -> String.slice(line, 0, 150)
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div class="mb-12">
          <h1 class="text-5xl font-bold text-gray-900 mb-4">
            Elixir プログラミング学習
          </h1>
          <p class="text-xl text-gray-600">
            基本的な構文や関数の書き方を学びましょう
          </p>
        </div>

        <!-- Progress Stats -->
        <div class="bg-white rounded-xl shadow-lg border-2 border-gray-200 p-8 mb-12">
          <h2 class="text-2xl font-bold text-gray-900 mb-6">学習進捗</h2>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div class="text-center p-6 bg-blue-50 rounded-lg">
              <div class="text-5xl font-bold text-blue-600 mb-2">
                {@stats.completed}
              </div>
              <div class="text-lg font-semibold text-gray-700">完了した問題</div>
            </div>
            <div class="text-center p-6 bg-gray-50 rounded-lg">
              <div class="text-5xl font-bold text-gray-700 mb-2">
                {@stats.total_exercises}
              </div>
              <div class="text-lg font-semibold text-gray-700">全問題数</div>
            </div>
            <div class="text-center p-6 bg-green-50 rounded-lg">
              <div class="text-5xl font-bold text-green-600 mb-2">
                {@stats.completion_percentage}%
              </div>
              <div class="text-lg font-semibold text-gray-700">達成率</div>
            </div>
          </div>
        </div>

        <!-- Exercise List -->
        <div class="space-y-6">
          <h2 class="text-3xl font-bold text-gray-900 mb-6">演習問題</h2>
          <%= for exercise <- @exercises do %>
            <.link
              navigate={~p"/playground/#{exercise.id}"}
              class="block bg-white rounded-xl shadow-md hover:shadow-xl transition-all duration-200 p-8 border-2 border-gray-200 hover:border-blue-300"
            >
              <div class="flex items-start justify-between">
                <div class="flex-1">
                  <div class="flex items-center gap-4 mb-4">
                    <h3 class="text-2xl font-bold text-gray-900">
                      {exercise.order}. {exercise.title}
                    </h3>
                    <span class="inline-flex items-center px-4 py-2 rounded-full text-base font-bold bg-blue-100 text-blue-800">
                      {exercise.difficulty}
                    </span>
                  </div>
                  <p class="text-gray-700 text-lg leading-relaxed">
                    {extract_first_line(exercise.description)}
                  </p>
                </div>
                <div class="ml-6 flex-shrink-0">
                  <svg
                    class="w-8 h-8 text-blue-500"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M9 5l7 7-7 7"
                    />
                  </svg>
                </div>
              </div>
            </.link>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
