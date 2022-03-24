defmodule Todo.Server do
  use GenServer

  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, Todo.List.new()}
  end

  # PUBLIC API
  def add_entry(entry) do
    GenServer.cast(__MODULE__, {:add_entry, entry})
  end

  def update_entry(%{} = new_entry) do
    GenServer.cast(__MODULE__, {:update_entry, new_entry})
  end

  def update_entry(entry_id, updater_fun) do
    GenServer.cast(__MODULE__, {:update_entry, entry_id, updater_fun})
  end

  def delete_entry(entry_id) do
    GenServer.cast(__MODULE__, {:delete_entry, entry_id})
  end

  def entries(date) do
    GenServer.call(__MODULE__, {:entries, date})
  end

  def all_entries() do
    GenServer.call(__MODULE__, {:all_entries, nil})
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
