defmodule Todo.RoundRobin do
  # def next_worker(worker_list, last_used) do
  #   worker =
  #     case do_next_worker(worker_list, last_used) do
  #       :not_found ->
  #         List.first(worker_list)

  #       worker ->
  #         worker
  #     end

  #   {worker_list, worker}
  # end

  # defp do_next_worker([], _) do
  #   :not_found
  # end

  # defp do_next_worker(_, nil) do
  #   :not_found
  # end

  # defp do_next_worker([worker | []], last_used) when last_used == worker do
  #   :not_found
  # end

  # defp do_next_worker([worker | worker_list], last_used) when last_used == worker do
  #   List.first(worker_list)
  # end

  # defp do_next_worker([_ | worker_list], last_used) do
  #   do_next_worker(worker_list, last_used)
  # end
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
