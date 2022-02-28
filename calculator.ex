defmodule Calculator do
  def start do
    spawn(fn ->
      loop(0)
    end)
  end

  defp loop(current_value) do
    new_value =
      receive do
        message -> process_message(current_value, message)
      end

    loop(new_value)
  end

  @doc """
  Returns the computed value
  """
  @spec value(pid) :: number
  def value(server_pid) do
    send(server_pid, {:value, self()})

    receive do
      {:result, value} ->
        value
    end
  end

  defp process_message(current_value, {:value, caller}) do
    send(caller, {:result, current_value})
    current_value
  end

  defp process_message(current_value, {:add, value}) do
    current_value + value
  end

  defp process_message(current_value, {:sub, value}) do
    current_value - value
  end

  defp process_message(current_value, {:div, value}) do
    current_value / value
  end

  defp process_message(current_value, {:mul, value}) do
    current_value * value
  end

  defp process_message(current_value, invalid_request) do
    IO.puts("Invalid request #{inspect(invalid_request)}")
    current_value
  end

  @spec add(pid, number) :: {atom, number}
  def add(server_pid, value), do: send(server_pid, {:add, value})
  def sub(server_pid, value), do: send(server_pid, {:sub, value})
  def div(server_pid, value), do: send(server_pid, {:div, value})
  def mul(server_pid, value), do: send(server_pid, {:mul, value})
end
