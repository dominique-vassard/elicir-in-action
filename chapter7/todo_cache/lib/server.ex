defmodule Todo.Server do
  use GenServer

  def start do
    GenServer.start(__MODULE__, nil)
  end

  @impl true
  def init(_) do
    {:ok, Todo.List.new()}
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
  def handle_cast({:add_entry, new_entry}, state) do
    {:noreply, Todo.List.add_entry(state, new_entry)}
  end

  @impl true
  def handle_cast({:update_entry, new_entry}, state) do
    {:noreply, Todo.List.update_entry(state, new_entry)}
  end

  @impl true
  def handle_cast({:update_entry, entry_id, updater_fun}, state) do
    {:noreply, Todo.List.update_entry(state, entry_id, updater_fun)}
  end

  @impl true
  def handle_cast({:delete_entry, entry_id}, state) do
    {:noreply, Todo.List.delete_entry(state, entry_id)}
  end

  @impl true
  def handle_call({:entries, date}, _, state) do
    {:reply, Todo.List.entries(state, date), state}
  end

  @impl true
  def handle_call({:all_entries, nil}, _, state) do
    {:reply, Todo.List.all_entries(state), state}
  end
end
