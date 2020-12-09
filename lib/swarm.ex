defmodule Swarm.Supervisor do
  use DynamicSupervisor
  def via(key), do: {:via, :swarm, key}
  def start_link(), do: DynamicSupervisor.start_link(__MODULE__, nil, name: __MODULE__)
  def init(_), do: DynamicSupervisor.init(strategy: :one_for_one)
  def register(child_spec), do: child_spec.id
    |> Swarm.register_name(Swarm.Supervisor, :start_child, [child_spec], 5_000)
  def start_child(child_spec), do: DynamicSupervisor.start_child(__MODULE__, child_spec)
end

defmodule Swarm.Distribution do
  use Swarm.Distribution.Strategy
  def create(), do: MapSet.new()
  def add_node(ring, node), do: MapSet.put(ring, node)
  def add_node(ring, node, _weight), do: MapSet.put(ring, node)
  def remove_node(ring, node), do: MapSet.delete(ring, node)
  def add_nodes(ring, nodes) do
    for n <- nodes, into: ring, do: n
  end
  def key_to_node(ring, key) do
    Cluster.Distribution.key_to_node(MapSet.to_list(ring), key)
  end
end
