defmodule Todo.DatabaseWorker do
  use GenServer

  def start(db_folder, name) do
    GenServer.start(__MODULE__, db_folder, name: name)
  end

  @impl true
  def init(db_folder) do
    {:ok, db_folder}
  end

  def store(worker_name, key, data) do
    GenServer.cast(worker_name, {:store, key, data})
  end

  def get(worker_name, key) do
    GenServer.call(worker_name, {:get, key})
  end

  def delete(worker_name, key) do
    GenServer.cast(worker_name, {:delete, key})
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
end
