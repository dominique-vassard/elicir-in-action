defmodule Todo.Server do
  use Agent, restart: :temporary

  def start_link(name) do
    Agent.start_link(
      fn ->
        IO.puts("Starting todo server for #{name}")
        {name, Todo.Database.get(name) || Todo.List.new()}
      end,
      name: via_tuple(name)
    )
  end

  # PUBLIC API
  def add_entry(server_pid, entry) do
    Agent.cast(server_pid, fn {name, todo_list} ->
      new_list = Todo.List.add_entry(todo_list, new_entry)
      Todo.Database.store(name, new_list)
      {name, new_list}
    end)
  end

  def update_entry(server_pid, %{} = new_entry) do
    Agent.cast(server_pid, fn {name, todo_list} ->
      new_todo_list = Todo.List.update_entry(todo_list, new_entry)
      Todo.Database.store(name, new_todo_list)

      {name, new_todo_list}
    end)
  end

  def update_entry(server_pid, entry_id, updater_fun) do
    Agent.cast(server_pid, fn {name, todo_list} ->
      new_todo_list = Todo.List.update_entry(todo_list, entry_id, updater_fun)
      Todo.Database.store(name, new_todo_list)

      {name, new_todo_list}
    end)
  end

  def delete_entry(server_pid, entry_id) do
    Agent.cast(server_pid, fn {name, todo_list} ->
      new_todo_list = Todo.List.delete_entry(todo_list, entry_id)
      Todo.Database.store(name, new_todo_list)

      {name, new_todo_list}
    end)
  end

  def entries(server_pid, date) do
    Agent.get(server_pid, fn [_, todo_list] ->
      data =
        name
        |> Todo.Database.get()
        |> Todo.List.entries(date)
    end)
  end

  def all_entries(server_pid) do
    Agent.get(server_pid, fn [_, todo_list] ->
      data =
        name
        |> Todo.Database.get()
        |> Todo.List.all_entries()
    end)
  end

  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end
end
