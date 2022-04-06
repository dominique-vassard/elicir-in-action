defmodule Todo.Server do
  use GenServer, restart: :temporary

  def start_link(name) do
    IO.puts("Starting todo server for #{name}")
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  @impl true
  def init(name) do
    send(self(), {:init_server, name})
    {:ok, nil}
  end

  # PUBLIC API
  def add_entry(server_pid, entry) do
    GenServer.cast(server_pid, {:add_entry, entry})
  end

  def update_entry(server_pid, %{} = new_entry) do
    GenServer.cast(server_pid, {:update_entry, new_entry})
  end

  def update_entry(server_pid, entry_id, updater_fun) do
    GenServer.cast(server_pid, {:update_entry, entry_id, updater_fun})
  end

  def delete_entry(server_pid, entry_id) do
    GenServer.cast(server_pid, {:delete_entry, entry_id})
  end

  def entries(server_pid, date) do
    GenServer.call(server_pid, {:entries, date})
  end

  def all_entries(server_pid) do
    GenServer.call(server_pid, {:all_entries, nil})
  end

  # INTERNALS
  @impl true
  def handle_info({:init_server, name}, _) do
    {:noreply, {name, Todo.Database.get(name) || Todo.List.new()}}
  end

  @impl true
  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_list = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_list)
    {:noreply, {name, new_list}}
  end

  @impl true
  def handle_cast({:update_entry, new_entry}, {name, todo_list}) do
    new_todo_list = Todo.List.update_entry(todo_list, new_entry)
    Todo.Database.store(name, new_todo_list)

    {:noreply, {name, new_todo_list}}
  end

  @impl true
  def handle_cast({:update_entry, entry_id, updater_fun}, {name, todo_list}) do
    new_todo_list = Todo.List.update_entry(todo_list, entry_id, updater_fun)
    Todo.Database.store(name, new_todo_list)

    {:noreply, {name, new_todo_list}}
  end

  @impl true
  def handle_cast({:delete_entry, entry_id}, {name, todo_list}) do
    new_todo_list = Todo.List.delete_entry(todo_list, entry_id)
    Todo.Database.store(name, new_todo_list)

    {:noreply, {name, new_todo_list}}
  end

  @impl true
  def handle_call({:entries, date}, _, {name, _} = state) do
    data =
      name
      |> Todo.Database.get()
      |> Todo.List.entries(date)

    {:reply, data, state}
  end

  @impl true
  def handle_call({:all_entries, nil}, _, {name, _} = state) do
    data =
      name
      |> Todo.Database.get()
      |> Todo.List.all_entries()

    {:reply, data, state}
  end

  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end
end
