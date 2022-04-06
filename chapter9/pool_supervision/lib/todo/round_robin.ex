defmodule Todo.RoundRobin do
  defstruct [:previous, :current, :next]

  def from_list(list) do
    init(list)
  end

  def current(%__MODULE__{current: current}) do
    current
  end

  def next(%__MODULE__{previous: list, current: current, next: []}) do
    init(list ++ [current])
  end

  def next(%__MODULE__{} = round_robin_list) do
    [current | rest] = round_robin_list.next

    %__MODULE__{
      round_robin_list
      | previous: round_robin_list.previous ++ [round_robin_list.current],
        current: current,
        next: rest
    }
  end

  defp init([start | rest]) do
    %__MODULE__{
      previous: [],
      current: start,
      next: rest
    }
  end
end
