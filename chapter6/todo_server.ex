defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
      &add_entry(&2, &1)
    )
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)
    new_entries = Map.put(todo_list.entries, todo_list.auto_id, entry)

    %TodoList{todo_list | entries: new_entries, auto_id: todo_list.auto_id + 1}
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def all_entries(todo_list) do
    todo_list.entries
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
  end

  def update_entry(todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        new_entry = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(todo_list, entry_id) do
    %TodoList{todo_list | entries: Map.delete(todo_list.entries, entry_id)}
  end
end

defmodule TodoServer do
  import ServerProcess

  def start do
    todo_server = ServerProcess.start(TodoServer)

    Process.register(todo_server, :todo_server)
  end

  def init do
    TodoList.new()
  end

  # PUBLIC API
  def add_entry(entry) do
    ServerProcess.cast(:todo_server, {:add_entry, entry})
  end

  def update_entry(%{} = new_entry) do
    ServerProcess.cast(:todo_server, {:update_entry, new_entry})
  end

  def update_entry(entry_id, updater_fun) do
    ServerProcess.cast(:todo_server, {:update_entry, entry_id, updater_fun})
  end

  def delete_entry(entry_id) do
    ServerProcess.cast(:todo_server, {:delete_entry, entry_id})
  end

  def entries(date) do
    ServerProcess.call(:todo_server, {:entries, date})
  end

  def all_entries() do
    ServerProcess.call(:todo_server, {:all_entries, nil})
  end

  # INTERNALS
  def handle_cast({:add_entry, new_entry}, state) do
    TodoList.add_entry(state, new_entry)
  end

  def handle_cast({:update_entry, new_entry}, state) do
    TodoList.update_entry(state, new_entry)
  end

  def handle_cast({:update_entry, entry_id, updater_fun}, state) do
    TodoList.update_entry(state, entry_id, updater_fun)
  end

  def handle_cast({:delete_entry, entry_id}, state) do
    TodoList.delete_entry(state, entry_id)
  end

  def handle_call({:entries, date}, state) do
    {TodoList.entries(state, date), state}
  end

  def handle_call({:all_entries, nil}, state) do
    {TodoList.all_entries(state), state}
  end
end

# WITH REGISTRY AND SERVER PROCESS

# c("chapter6/server_process.ex")
# c("chapter6/todo_server.ex")
# TodoServer.start()
# TodoServer.add_entry(%{date: ~D[2021-01-05], title: "first"})
# TodoServer.add_entry(%{date: ~D[2021-05-25], title: "again"})
# TodoServer.add_entry(%{date: ~D[2021-01-05], title: "New one"})
# TodoServer.entries(~D[2021-01-05])
# TodoServer.update_entry(%{id: 1, date: ~D[2021-05-25], title: "Very first"})
# TodoServer.entries(~D[2021-01-05])
# TodoServer.entries(~D[2021-05-25])
# TodoServer.update_entry(1, fn %{} = e -> %{e | title: "5"} end)
# TodoServer.entries(~D[2021-05-25])
# TodoServer.delete_entry(1)
# TodoServer.entries(~D[2021-05-25])
# TodoServer.all_entries()
