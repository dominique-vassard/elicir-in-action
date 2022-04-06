# CHAPTER 9: Isolating error effects

### Supervision tree
iex(1)> Todo.System.start_link
Starting todo cache
Starting database server
Starting database worker
Starting database worker
Starting database worker
{:ok, #PID<0.175.0>}
iex(2)> Todo.Database |> Process.whereis |> Process.exit(:kill)
Starting database server
true
Starting database worker
Starting database worker
Starting database worker
iex(3)> 