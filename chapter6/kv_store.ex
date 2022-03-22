import ServerProcess

defmodule KeyValueStore do
  def start do
    ServerProcess.start(KeyValueStore)
  end

  def put(pid, key, value) do
    ServerProcess.cast(pid, {:put, key, value})
  end

  def get(pid, key) do
    ServerProcess.call(pid, {:get, key})
  end

  # Initial process state
  def init() do
    %{}
  end

  @doc """
  Handles asynchronous requests
  """
  def handle_cast({:put, key, value}, state) do
    Map.put(state, key, value)
  end

  @doc """
  Handles synchronous requests
  """
  def handle_call({:get, key}, state) do
    {Map.get(state, key), state}
  end
end
