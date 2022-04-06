defmodule TodoCacheTest do
  use ExUnit.Case, async: true

  test "server_process" do
    {:ok, cache} = Todo.Cache.start()
    bob_pid = Todo.Cache.server_process(cache, "bob")

    assert bob_pid != Todo.Cache.server_process(cache, "alice")
    assert bob_pid == Todo.Cache.server_process(cache, "bob")
  end

  test "todo operations" do
    {:ok, cache} = Todo.Cache.start()
    alice_pid = Todo.Cache.server_process(cache, "alice")

    Todo.Server.add_entry(alice_pid, %{date: ~D[2021-01-05], title: "Dentist"})
    entries = Todo.Server.entries(alice_pid, ~D[2021-01-05])

    assert [%{date: ~D[2021-01-05], title: "Dentist"}] = entries
  end
end
