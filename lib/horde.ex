defmodule Horde.Supervisor do
  use Supervisor
  def via(id), do: {:via, Horde.Registry, {__MODULE__.Registry, id}}
  def start_link(), do: Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  def init(_) do
    Supervisor.init([
      {Horde.Registry, [name: __MODULE__.Registry, keys: :unique]},
      {Horde.DynamicSupervisor, [name: __MODULE__.Supervisor,
        members: :auto,
        strategy: :one_for_one,
        distribution_strategy: Horde.Distribution,
      ]},
    ], strategy: :one_for_one)
  end
  def start_child(child_spec) do
    Horde.DynamicSupervisor.start_child(__MODULE__.Supervisor, child_spec)
  end
  def register(%{start: {m, f, [n]}} = child_spec) do
    start_child(%{child_spec
      | start: {m, f, [n, [name: via(child_spec.id)]]}})
    |> case do
      {:error, {:already_registered, _pid}} ->
        {:error, :already_exists}
      other -> other
    end
  end
  # def whereis(id) do
  # end
  # def join(group) do: Swarm.join(group, self())
  # def leave(group) do: Swarm.leave(group, self())
end

defmodule Horde.Distribution do
  @behaviour Horde.DistributionStrategy
  def has_quorum?(_nodes), do: true
  def choose_node(key, nodes) do
    nodes = for node <- nodes,
      match?(%{status: :alive}, node),
      into: %{}, do: {node.name, node}
    case Cluster.Distribution.key_to_node(Map.keys(nodes), key) do
      {:error, {_, :no_nodes}} -> {:error, :no_alive_nodes}
      name -> {:ok, nodes[name]}
    end
  end
end
