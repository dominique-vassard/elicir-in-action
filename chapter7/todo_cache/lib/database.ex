defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    File.mkdir_p!(@db_folder)
    {:ok, nil}
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
    key
    |> filename()
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, state}
  end

  @impl true
  def handle_cast({:delete, key}, state) do
    key
    |> filename()
    |> File.rm!()

    {:noreply, state}
  end

  @impl true
  def handle_call({:get, key}, _, state) do
    data =
      key
      |> filename()
      |> File.read!()
      |> :erlang.binary_to_term()

    {:reply, data, state}
  end

  defp filename(key) do
    Path.join(@db_folder, to_string(key))
  end
end
