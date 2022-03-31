defmodule Todo.Database do
  alias Todo.RoundRobin
  use GenServer

  @db_folder "./persist"

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    File.mkdir_p!(@db_folder)

    worker_list =
      Enum.map(1..3, fn index ->
        worker_name = :"worker#{index}"
        Todo.DatabaseWorker.start(@db_folder, worker_name)
        worker_name
      end)

    {:ok, {RoundRobin.from_list(worker_list), %{}}}
  end

  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def delete(key) do
    GenServer.cast(__MODULE__, {:delete, key})
  end

  @impl true
  def handle_cast({:store, key, data}, state) do
    {worker, worker_list, registry} =
      key
      |> worker(state)

    Todo.DatabaseWorker.store(worker, key, data)

    {:noreply, {worker_list, registry}}
  end

  @impl true
  def handle_cast({:delete, key}, state) do
    {worker, worker_list, registry} =
      key
      |> worker(state)

    Todo.DatabaseWorker.delete(worker, key)

    {:noreply, {worker_list, registry}}
  end

  @impl true
  def handle_call({:get, key}, _, state) do
    {worker, worker_list, registry} =
      key
      |> worker(state)

    IO.inspect(worker)

    {:reply, Todo.DatabaseWorker.get(worker, key), {worker_list, registry}}
  end

  defp worker(key, {worker_list, registry}) do
    case Map.fetch(registry, key) do
      {:ok, worker} ->
        {worker, worker_list, registry}

      :error ->
        {RoundRobin.current(worker_list), RoundRobin.next(worker_list),
         Map.put(registry, key, RoundRobin.current(worker_list))}
    end
  end
end
