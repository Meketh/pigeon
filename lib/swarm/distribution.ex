defmodule Swarm.Distribution do
  use Swarm.Distribution.Strategy
  def create(), do: MapSet.new()
  def add_node(ring, node), do: MapSet.put(ring, node)
  def add_node(ring, node, _weight), do: MapSet.put(ring, node)
  def remove_node(ring, node), do: MapSet.delete(ring, node)
  def add_nodes(ring, nodes) do
    for n <- nodes, into: ring, do: n
  end

  def key_to_node(ring, {id, r}) do
    id_to_node(MapSet.to_list(ring), id, r)
  end
  def key_to_node(ring, {id}) do
    id_to_node(MapSet.to_list(ring), id)
  end

  defp id_to_node(nodes, id, 1), do: id_to_node(nodes, id)
  defp id_to_node(nodes, id, replica) do
    node = id_to_node(nodes, id)
    case Enum.filter(nodes, &(&1 != node)) do
      [] -> node
      rest -> id_to_node(rest, id, replica - 1)
    end
  end
  defp id_to_node(nodes, id) do
    HashRing.new()
    |> HashRing.add_nodes(nodes)
    |> HashRing.key_to_node(id)
  end
end
