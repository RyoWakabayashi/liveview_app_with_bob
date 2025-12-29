defmodule ElixirPlayground.CodeExecutor do
  @moduledoc """
  Executes Elixir code in a sandboxed environment with timeout and memory limits.
  """

  @timeout 5_000  # 5 seconds
  @max_memory 50_000_000  # 50 MB in bytes

  @doc """
  Executes the given Elixir code string and returns the result.

  ## Options
    * `:timeout` - Maximum execution time in milliseconds (default: 5000)

  ## Examples

      iex> CodeExecutor.execute("1 + 1")
      {:ok, 2}

      iex> CodeExecutor.execute("invalid code")
      {:error, "compilation error"}
  """
  def execute(code, opts \\ []) do
    timeout = Keyword.get(opts, :timeout, @timeout)

    # Validate code before execution
    with :ok <- validate_code(code),
         {:ok, result} <- execute_in_sandbox(code, timeout) do
      {:ok, result}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp validate_code(code) do
    # Check for dangerous patterns
    dangerous_patterns = [
      ~r/System\./,
      ~r/File\./,
      ~r/:os\./,
      ~r/:erlang\.halt/,
      ~r/spawn/,
      ~r/Process\.exit/,
      ~r/__ENV__/,
      ~r/__CALLER__/,
      ~r/Code\.eval/,
      ~r/Code\.compile/,
      ~r/:code\./
    ]

    if Enum.any?(dangerous_patterns, &Regex.match?(&1, code)) do
      {:error, "コードに許可されていない関数が含まれています"}
    else
      :ok
    end
  end

  defp execute_in_sandbox(code, timeout) do
    parent = self()

    # Spawn a separate process to execute the code
    {pid, ref} =
      spawn_monitor(fn ->
        try do
          # Compile and evaluate the code
          {result, _binding} = Code.eval_string(code, [], file: "playground", line: 1)
          send(parent, {:result, result})
        rescue
          error ->
            send(parent, {:error, format_exception(error, __STACKTRACE__)})
        catch
          kind, reason ->
            send(parent, {:error, "#{kind}: #{inspect(reason)}"})
        end
      end)

    # Set memory limit (this is a soft limit check)
    Process.send_after(self(), {:check_memory, pid}, 100)

    # Wait for result with timeout
    receive do
      {:result, result} ->
        Process.demonitor(ref, [:flush])
        {:ok, result}

      {:error, error} ->
        Process.demonitor(ref, [:flush])
        {:error, error}

      {:DOWN, ^ref, :process, ^pid, :normal} ->
        receive do
          {:result, result} -> {:ok, result}
          {:error, error} -> {:error, error}
        after
          0 -> {:error, "プロセスが予期せず終了しました"}
        end

      {:DOWN, ^ref, :process, ^pid, reason} ->
        {:error, "実行エラー: #{inspect(reason)}"}

      {:check_memory, ^pid} ->
        case check_process_memory(pid) do
          :ok ->
            Process.send_after(self(), {:check_memory, pid}, 100)
            execute_in_sandbox_continue(pid, ref, timeout)

          {:error, reason} ->
            Process.exit(pid, :kill)
            Process.demonitor(ref, [:flush])
            {:error, reason}
        end
    after
      timeout ->
        Process.exit(pid, :kill)
        Process.demonitor(ref, [:flush])
        {:error, "実行がタイムアウトしました（#{timeout}ms）"}
    end
  end

  defp execute_in_sandbox_continue(pid, ref, timeout) do
    receive do
      {:result, result} ->
        Process.demonitor(ref, [:flush])
        {:ok, result}

      {:error, error} ->
        Process.demonitor(ref, [:flush])
        {:error, error}

      {:DOWN, ^ref, :process, ^pid, :normal} ->
        receive do
          {:result, result} -> {:ok, result}
          {:error, error} -> {:error, error}
        after
          0 -> {:error, "プロセスが予期せず終了しました"}
        end

      {:DOWN, ^ref, :process, ^pid, reason} ->
        {:error, "実行エラー: #{inspect(reason)}"}

      {:check_memory, ^pid} ->
        case check_process_memory(pid) do
          :ok ->
            Process.send_after(self(), {:check_memory, pid}, 100)
            execute_in_sandbox_continue(pid, ref, timeout)

          {:error, reason} ->
            Process.exit(pid, :kill)
            Process.demonitor(ref, [:flush])
            {:error, reason}
        end
    after
      timeout ->
        Process.exit(pid, :kill)
        Process.demonitor(ref, [:flush])
        {:error, "実行がタイムアウトしました（#{timeout}ms）"}
    end
  end

  defp check_process_memory(pid) do
    case Process.info(pid, :memory) do
      {:memory, bytes} when bytes > @max_memory ->
        {:error, "メモリ使用量が制限を超えました（#{bytes} bytes）"}

      {:memory, _bytes} ->
        :ok

      nil ->
        {:error, "プロセスが存在しません"}
    end
  end

  defp format_exception(%CompileError{} = error, _stacktrace) do
    """
    コンパイルエラー:
    #{error.description}
    行 #{error.line}
    """
  end

  defp format_exception(%SyntaxError{} = error, _stacktrace) do
    """
    構文エラー:
    #{error.description}
    行 #{error.line}
    """
  end

  defp format_exception(%TokenMissingError{} = error, _stacktrace) do
    """
    構文エラー:
    #{error.description}
    行 #{error.line}
    """
  end

  defp format_exception(error, stacktrace) do
    """
    実行時エラー:
    #{Exception.message(error)}

    #{format_stacktrace(stacktrace)}
    """
  end

  defp format_stacktrace(stacktrace) do
    stacktrace
    |> Enum.take(5)
    |> Enum.map(fn entry ->
      case entry do
        {module, function, arity, location} ->
          file = Keyword.get(location, :file, "unknown")
          line = Keyword.get(location, :line, 0)
          "  #{inspect(module)}.#{function}/#{arity} (#{file}:#{line})"

        _ ->
          "  #{inspect(entry)}"
      end
    end)
    |> Enum.join("\n")
  end
end
