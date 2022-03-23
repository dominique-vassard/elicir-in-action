defmodule KeyValueStore do
  use GenServer

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def put(key, value) do
    GenServer.cast(__MODULE__, {:put, key, value})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  # Initial process state
  @impl true
  def init(_) do
    :timer.send_interval(5000, :cleanup)
    {:ok, %{}}
  end

  @doc """
  Handles asynchronous requests
  """
  @impl true
  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  @doc """
  Handles synchronous requests
  """
  @impl true
  def handle_call({:get, key}, _, state) do
    {:reply, Map.get(state, key), state}
  end

  @impl true
  def handle_info(:cleanup, state) do
    IO.puts("performing cleanup...")
    {:noreply, state}
  end
end

# c("chapter6/gen_server/kv_store.ex")
# KeyValueStore.start()
# KeyValueStore.put(:some_key, :some_value)
# KeyValueStore.get(:some_key)
# GenServer.stop(KeyValueStore)
