defmodule Todo.DatabaseWorker do
  use GenServer

  def start_link({db_folder, worker_id}) do
    IO.puts("Starting  worker #{worker_id}")
    GenServer.start_link(__MODULE__, db_folder, name: via_tuple(worker_id))
  end

  @impl true
  def init(db_folder) do
    {:ok, db_folder}
  end

  def store(worker_id, key, data) do
    GenServer.cast(via_tuple(worker_id), {:store, key, data})
  end

  def get(worker_id, key) do
    GenServer.call(via_tuple(worker_id), {:get, key})
  end

  def delete(worker_id, key) do
    GenServer.cast(via_tuple(worker_id), {:delete, key})
  end

  @impl true
  def handle_cast({:store, key, data}, db_folder) do
    spawn(fn ->
      key
      |> filename(db_folder)
      |> File.write!(:erlang.term_to_binary(data))
    end)

    {:noreply, db_folder}
  end

  @impl true
  def handle_cast({:delete, key}, db_folder) do
    spawn(fn ->
      key
      |> filename(db_folder)
      |> File.rm!()
    end)

    {:noreply, db_folder}
  end

  @impl true
  def handle_call({:get, key}, caller, db_folder) do
    spawn(fn ->
      fetched_data =
        key
        |> filename(db_folder)
        |> File.read()

      data =
        case fetched_data do
          {:ok, new_data} -> :erlang.binary_to_term(new_data)
          {:error, _} -> nil
        end

      GenServer.reply(caller, data)
    end)

    {:noreply, db_folder}
  end

  defp filename(key, db_folder) do
    Path.join(db_folder, to_string(key))
  end

  defp via_tuple(worker_id) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, worker_id})
  end
end
