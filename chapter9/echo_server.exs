defmodule EchoServer do
  use GenServer

  def start_link(id) do
    GenServer.start_link(__MODULE__, nil, name: via_tuple(id))
  end

  def call(id, request) do
    GenServer.call(via_tuple(id), request)
  end

  defp via_tuple(id) do
    {:via, Registry, {:local, {__MODULE__, id}}}
  end

  # Indicates an upcoming definition of a callback function
  # Useful to raise error at compile time
  @impl true
  def handle_call(some_request, _, server_state) do
    {:reply, some_request, server_state}
  end
end
