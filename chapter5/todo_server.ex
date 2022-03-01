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
  import TodoList

  def start do
    todo_server =
      spawn(fn ->
        loop(TodoList.new())
      end)

    Process.register(todo_server, :todo_server)
  end

  def loop(todo_list) do
    new_todo_list =
      receive do
        message ->
          process_message(todo_list, message)
      end

    loop(new_todo_list)
  end

  # Interface
  def add_entry(entry) do
    send(:todo_server, {:add_entry, entry})
  end

  def entries(date) do
    send(:todo_server, {:entries, self(), date})

    receive do
      {:todo_entries, entries} -> entries
    after
      5000 -> {:error, :timeout}
    end
  end

  def all_entries() do
    send(:todo_server, {:all_entries, self()})

    receive do
      {:todo_all_entries, entries} -> entries
    after
      5000 -> {:error, :timeout}
    end
  end

  def update_entry(%{} = new_entry) do
    send(:todo_server, {:update_entry, new_entry})
  end

  def update_entry(entry_id, updater_fun) do
    send(:todo_server, {:update_entry, entry_id, updater_fun})
  end

  def delete_entry(entry_id) do
    send(:todo_server, {:delete_entry, entry_id})
  end

  # Internals
  defp process_message(todo_list, {:add_entry, new_entry}) do
    TodoList.add_entry(todo_list, new_entry)
  end

  defp process_message(todo_list, {:entries, caller, date}) do
    send(caller, {:todo_entries, TodoList.entries(todo_list, date)})
    todo_list
  end

  defp process_message(todo_list, {:all_entries, caller}) do
    send(caller, {:todo_all_entries, TodoList.all_entries(todo_list)})
    todo_list
  end

  defp process_message(todo_list, {:update_entry, %{} = new_entry}) do
    TodoList.update_entry(todo_list, new_entry)
  end

  defp process_message(todo_list, {:update_entry, entry_id, updater_fun}) do
    TodoList.update_entry(todo_list, entry_id, updater_fun)
  end

  defp process_message(todo_list, {:delete_entry, entry_id}) do
    TodoList.delete_entry(todo_list, entry_id)
  end
end

# TESTING
#
# wITHOUT REGISTRY
#
# c("chapter5/todo_server.ex")
# todo_server = TodoServer.start
# TodoServer.add_entry(todo_server, %{date: ~D[2021-01-05], title: "first"})
# TodoServer.add_entry(todo_server, %{date: ~D[2021-05-25], title: "again"})
# TodoServer.add_entry(todo_server, %{date: ~D[2021-01-05], title: "New one"})
# TodoServer.entries(todo_server, ~D[2021-01-05])
# TodoServer.update_entry(todo_server, %{id: 1, date: ~D[2021-05-25], title: "Very first"})
# TodoServer.entries(todo_server, ~D[2021-01-05])
# TodoServer.entries(todo_server, ~D[2021-05-25])
# TodoServer.update_entry(todo_server, 1, fn %{} = e -> %{e | title: "5"} end)
# TodoServer.entries(todo_server, ~D[2021-05-25])
# TodoServer.delete_entry(todo_server, 1)
# TodoServer.entries(todo_server, ~D[2021-05-25])
# TodoServer.all_entries(todo_server)
#
# wITH REGISTRY

# c("chapter5/todo_server.ex")
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
