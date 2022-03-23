defmodule EchoServer do
  use GenServer

  # Indicates an upcoming definition of a callback function
  # Useful to raise error at compile time
  @impl true
  def handle_call(some_request, _, server_state) do
    {:reply, some_request, server_state}
  end
end
