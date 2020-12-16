defmodule Swarm.Agent do
  alias Swarm.Supervisor, as: SS
  def unreplicate(id), do: SS.unreplicate(id)
  def replicate(id) do
    SS.replicate(%{id: id,
    start: {__MODULE__, :start_store, []}})
  end
  def start_store(id, _r) do
    {:ok, pid} = DeltaCrdt.start_link(DeltaCrdt.AWLWWMap)
    Task.async(fn->
      Swarm.join(id, pid)
      pids = id
      |> Swarm.members()
      |> Enum.filter(&is_pid/1)
      Enum.map(pids, &DeltaCrdt.set_neighbours(&1, pids))
    end)
    {:ok, pid}
  end

  def read(id) do
    SS.do_any(DeltaCrdt, :read, id)
  end
  def write(id, key, value) do
    SS.do_any(DeltaCrdt, :mutate, id, [:add, [key, value]])
  end
  def remove(id, key) do
    SS.do_any(DeltaCrdt, :mutate, id, [:remove, [key]])
  end
  def write_async(id, key, value) do
    SS.do_any(DeltaCrdt, :mutate_async, id, [:add, [key, value]])
  end
  def remove_async(id, key) do
    SS.do_any(DeltaCrdt, :mutate_async, id, [:remove, [key]])
  end
end
