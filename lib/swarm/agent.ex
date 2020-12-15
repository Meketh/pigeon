defmodule Swarm.Agent do
  alias Swarm.Supervisor, as: SS
  def exists(id), do: SS.replicated(id)
  def replicate(id, stores), do: SS.replicate(child_spec(id, stores))

  def child_spec(id, stores) do
    %{id: id, type: :supervisor, restart: :transient,
    start: {__MODULE__, :start_link, [id, stores]}}
  end
  def start_link(id, stores) do
    GenServer.start_link(Swarm.Agent.Server, {id, stores})
  end

  def store_spec(id, store) do
    %{id: store, type: :worker, restart: :permanent,
    start: {__MODULE__, :start_store, [id, store]}}
  end
  def start_store(id, store) do
    {:ok, pid} = DeltaCrdt.start_link(DeltaCrdt.AWLWWMap)
    neighbours = [pid | get_stores(id, store)] |> Enum.filter(&(&1))
    for n <- neighbours,
    do: DeltaCrdt.set_neighbours(n, neighbours)
    {:ok, pid}
  end

  def get_stores(id, store), do: Swarm.multi_call(id, {:store, store})
  def set_all(id, path, value), do: Swarm.multi_call(id, {:get, path, value})
  def get_all(id, path), do: Swarm.multi_call(id, {:get, path})
  def get_all(id, path, fun), do: Swarm.multi_call(id, {:get, path, fun})
  def get_and_update_all(id, fun), do: Swarm.multi_call(id, {:get_and_update, fun})
  def get_and_update_all(id, path, fun), do: Swarm.multi_call(id, {:get_and_update, path, fun})
  def update_all(id, fun), do: Swarm.multi_call(id, {:update, fun})
  def update_all(id, path, fun), do: Swarm.multi_call(id, {:update, path, fun})
  def cast_all(id, fun), do: Swarm.publish(id, {:cast, fun})
  def cast_all(id, path, fun), do: Swarm.publish(id, {:cast, path, fun})

  def set(id, path, value), do: SS.call_any(id, {:set, path, value})
  def get(id, path), do: SS.call_any(id, {:get, path})
  def get(id, path, fun), do: SS.call_any(id, {:get, path, fun})
  def get_and_update(id, fun), do: SS.call_any(id, {:get_and_update, fun})
  def get_and_update(id, path, fun), do: SS.call_any(id, {:get_and_update, path, fun})
  def update(id, fun), do: SS.call_any(id, {:update, fun})
  def update(id, path, fun), do: SS.call_any(id, {:update, path, fun})
  def cast(id, fun), do: SS.cast_any(id, {:cast, fun})
  def cast(id, path, fun), do: SS.cast_any(id, {:cast, path, fun})
end
