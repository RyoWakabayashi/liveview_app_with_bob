defmodule ElixirPlaygroundWeb.PlaygroundLive.Show do
  use ElixirPlaygroundWeb, :live_view

  alias ElixirPlayground.Learning
  alias ElixirPlayground.CodeExecutor

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    exercise = Learning.get_exercise!(id)
    user_id = socket.assigns.current_scope.user.id

    # Get or create user progress
    {:ok, progress} = Learning.get_or_create_progress(user_id, exercise.id)

    # Use last saved code or initial code
    initial_code = progress.last_code || exercise.initial_code || ""

    {:ok,
     socket
     |> assign(:exercise, exercise)
     |> assign(:progress, progress)
     |> assign(:code, initial_code)
     |> assign(:output, nil)
     |> assign(:error, nil)
     |> assign(:success, false)
     |> assign(:executing, false)
     |> assign(:page_title, exercise.title)}
  end

  @impl true
  def handle_event("update_code", %{"code" => code}, socket) do
    {:noreply, assign(socket, :code, code)}
  end

  @impl true
  def handle_event("run_code", params, socket) do
    require Logger
    Logger.info("run_code event received with params: #{inspect(params)}")

    code = params["code"] || socket.assigns.code
    Logger.info("Code to execute: #{inspect(code)}")

    user_id = socket.assigns.current_scope.user.id
    exercise = socket.assigns.exercise

    # Save the code
    Learning.update_progress_code(user_id, exercise.id, code)

    # Execute the code
    socket = assign(socket, :executing, true)

    case CodeExecutor.execute(code) do
      {:ok, result} ->
        output = inspect(result, pretty: true)
        success = check_success(output, exercise.expected_output)

        # Mark as completed if successful
        if success do
          Learning.mark_exercise_completed(user_id, exercise.id)
        end

        {:noreply,
         socket
         |> assign(:output, output)
         |> assign(:error, nil)
         |> assign(:success, success)
         |> assign(:executing, false)}

      {:error, error} ->
        {:noreply,
         socket
         |> assign(:output, nil)
         |> assign(:error, format_error(error))
         |> assign(:success, false)
         |> assign(:executing, false)}
    end
  end

  @impl true
  def handle_event("reset_code", _params, socket) do
    exercise = socket.assigns.exercise
    initial_code = exercise.initial_code || ""

    {:noreply,
     socket
     |> assign(:code, initial_code)
     |> assign(:output, nil)
     |> assign(:error, nil)
     |> assign(:success, false)}
  end

  defp check_success(output, expected_output) do
    # Normalize both strings for comparison
    normalize(output) == normalize(expected_output)
  end

  defp normalize(str) do
    str
    |> String.trim()
    |> String.replace(~r/\s+/, " ")
  end

  defp format_error(error) when is_binary(error), do: error
  defp format_error(error), do: inspect(error)

  defp format_markdown(text) do
    text
    |> String.replace(~r/\*\*(.+?)\*\*/, "<strong>\\1</strong>")
    |> String.replace(~r/`(.+?)`/, "<code class=\"bg-gray-800 text-white px-3 py-1 rounded text-base font-mono font-semibold\">\\1</code>")
    |> String.split("\n")
    |> Enum.map(fn line ->
      cond do
        String.starts_with?(line, "**") and String.ends_with?(line, "**") ->
          content = String.slice(line, 2..(String.length(line) - 3))
          "<h3 class=\"font-bold text-lg mt-4 mb-2\">#{content}</h3>"
        String.starts_with?(line, "- ") ->
          content = String.slice(line, 2..-1//1)
          "<li class=\"ml-4\">#{content}</li>"
        String.trim(line) == "" ->
          "<br>"
        true ->
          "<p class=\"mb-2\">#{line}</p>"
      end
    end)
    |> Enum.join("\n")
    |> Phoenix.HTML.raw()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Header -->
        <div class="mb-8">
          <.link navigate={~p"/playground"} class="text-blue-600 hover:text-blue-800 mb-4 inline-flex items-center font-semibold text-lg">
            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
            </svg>
            演習問題一覧に戻る
          </.link>
          <h1 class="text-4xl font-bold text-gray-900 mb-3 mt-4">
            {@exercise.order}. {@exercise.title}
          </h1>
          <span class="inline-flex items-center px-4 py-2 rounded-full text-base font-semibold bg-blue-100 text-blue-800">
            {@exercise.difficulty}
          </span>
        </div>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Left Column: Description -->
        <div class="space-y-6">
          <div class="bg-white rounded-lg shadow-md border border-gray-200 p-8">
            <h2 class="text-2xl font-bold text-gray-900 mb-6">問題文</h2>
            <div class="prose prose-lg max-w-none text-gray-800 leading-relaxed">
              {format_markdown(@exercise.description)}
            </div>
          </div>

          <!-- Output Section -->
          <div class="bg-white rounded-lg shadow-md border border-gray-200 p-8">
            <h2 class="text-2xl font-bold text-gray-900 mb-6">実行結果</h2>

            <%= if @executing do %>
              <div class="flex items-center justify-center py-8">
                <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
                <span class="ml-3 text-gray-600">実行中...</span>
              </div>
            <% end %>

            <%= if @success do %>
              <div class="bg-green-50 border-2 border-green-300 rounded-lg p-6 mb-4">
                <div class="flex items-center">
                  <svg
                    class="w-8 h-8 text-green-600 mr-3"
                    fill="currentColor"
                    viewBox="0 0 20 20"
                  >
                    <path
                      fill-rule="evenodd"
                      d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                      clip-rule="evenodd"
                    />
                  </svg>
                  <span class="text-green-900 font-bold text-xl">正解です！</span>
                </div>
              </div>
            <% end %>

            <%= if @error do %>
              <div class="bg-red-50 border-2 border-red-300 rounded-lg p-6">
                <h3 class="text-red-900 font-bold text-lg mb-3">エラー</h3>
                <pre class="text-base text-red-800 whitespace-pre-wrap font-mono leading-relaxed">{@error}</pre>
              </div>
            <% end %>

            <%= if @output && !@executing do %>
              <div class="bg-gray-50 border border-gray-300 rounded-lg p-6">
                <h3 class="text-gray-900 font-bold text-lg mb-3">出力</h3>
                <pre class="text-base text-gray-800 whitespace-pre-wrap font-mono leading-relaxed">{@output}</pre>
              </div>
            <% end %>

            <%= if !@output && !@error && !@executing do %>
              <p class="text-gray-500 text-center py-8">
                コードを実行すると、ここに結果が表示されます
              </p>
            <% end %>
          </div>
        </div>

        <!-- Right Column: Code Editor -->
        <div class="space-y-4">
          <div class="bg-white rounded-lg shadow-md border border-gray-200 p-8">
            <h2 class="text-2xl font-bold text-gray-900 mb-6">コードエディタ</h2>

            <form phx-submit="run_code" class="space-y-4">
              <div>
                <textarea
                  name="code"
                  phx-hook="CodeEditor"
                  id="code-editor"
                  rows="22"
                  class="w-full px-5 py-4 border-2 border-gray-400 rounded-lg font-mono text-lg leading-loose focus:ring-2 focus:ring-blue-500 focus:border-blue-500 bg-white text-gray-900"
                  placeholder="ここにコードを書いてください..."
                  phx-debounce="300"
                  phx-change="update_code"
                  style="line-height: 1.8; color: #111827;"
                >{@code}</textarea>
              </div>

              <div class="flex gap-3">
                <button
                  type="submit"
                  disabled={@executing}
                  class="flex-1 bg-blue-600 hover:bg-blue-700 disabled:bg-gray-400 text-white font-bold text-lg py-4 px-8 rounded-lg transition-colors shadow-sm"
                >
                  <%= if @executing do %>
                    実行中...
                  <% else %>
                    実行
                  <% end %>
                </button>

                <button
                  type="button"
                  phx-click="reset_code"
                  class="bg-gray-200 hover:bg-gray-300 text-gray-700 font-bold text-lg py-4 px-8 rounded-lg transition-colors"
                >
                  リセット
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
      </div>
    </div>
    """
  end
end
