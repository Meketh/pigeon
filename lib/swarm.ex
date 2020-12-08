defmodule Swarm.Distribution do
  use Swarm.Distribution.Strategy
  def create(), do: HashRing.new()
  def add_node(ring, node), do: HashRing.add_node(ring, node)
  def add_node(ring, node, weight), do: HashRing.add_node(ring, node, weight)
  def add_nodes(ring, nodes), do: HashRing.add_nodes(ring, nodes)
  def remove_node(ring, node), do: HashRing.remove_node(ring, node)
  def key_to_node(ring, key) do
    node = HashRing.key_to_node(ring, key)
    :logger.debug("#{if node == Node.self, do: "L", else: "R"}/#{inspect key}")
    node
  end
end

defmodule Swarm.Supervisor do
  use DynamicSupervisor
  def start_link(_), do: DynamicSupervisor.start_link(__MODULE__, nil, name: __MODULE__)
  def init(_), do: DynamicSupervisor.init(strategy: :one_for_one)
  def register(child_spec), do: DynamicSupervisor.start_child(__MODULE__, child_spec)
  defmacro __using__(_opts) do
    quote do
      def id(name), do: {__MODULE__, name}
      # def id(name), do: "#{__MODULE__}_#{name}"
      def via(name), do: {:via, :swarm, id(name)}
      def child_spec(name), do: %{
        id: id(name),
        restart: :transient,
        start: {__MODULE__, :start_link, [name]},
      }
      def new(name) do
        # case Swarm.Supervisor.register(child_spec(name)) do
        case Swarm.register_name(id(name),
          Swarm.Supervisor, :register, [child_spec(name)]
        ) do
          {:ok, pid} -> {:ok, pid}
          {:error, {:already_registered, pid}} -> {:ok, pid}
          error -> error
        end
      end
      # Swarm.Callbacks / Handoff: :restart | :ignore | {:resume, handoff}
      def handle_call({:swarm, :begin_handoff}, _from, state), do: {:reply, :restart, state}
      def handle_cast({:swarm, :end_handoff, _handoff}, state), do: {:noreply, state}
      def handle_cast({:swarm, :resolve_conflict, _conflict}, state), do: {:noreply, state}
      def handle_info({:swarm, :die}, state), do: {:stop, :shutdown, state}
    end
  end
end
