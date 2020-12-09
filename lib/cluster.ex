defmodule Cluster.Supervisor do
  @supervisor Swarm.Supervisor
  def via(key), do: @supervisor.via(key)
  def start_link(), do: @supervisor.start_link()
  def register(child_spec), do: @supervisor.register(child_spec)
end

defmodule Cluster.Distribution do
  def key_to_node(nodes, key, 0), do: key_to_node(nodes, key)
  def key_to_node(nodes, key, replica) do
    prev = key_to_node(nodes, key)
    rest = Enum.filter(nodes, &(&1 != prev))
    key_to_node(rest, key, replica - 1)
  end
  def key_to_node(nodes, key) do
    HashRing.new()
    |> HashRing.add_nodes(nodes)
    |> HashRing.key_to_node(key)
  end
end

defmodule Cluster.Agent do
  defmacro __using__(_opts) do
    quote do
      use Agent
      def get(name, fun, args \\ []), do: Agent.get(via(name), __MODULE__, fun, args)
      # Cluster
      def key(name), do: {__MODULE__, name}
      def via(name), do: Cluster.Supervisor.via(key(name))
      def start_link(name, ops \\ []) do
        Agent.start_link(__MODULE__, :init, [name], ops)
      end
      def child_spec(name), do: %{
        id: key(name),
        shutdown: 10_000,
        restart: :transient,
        start: {__MODULE__, :start_link, [name]},
      }
      def new(name) do
        case Cluster.Supervisor.register(child_spec(name)) do
          {:ok, pid} -> {:ok, pid}
          {:error, {:already_started, pid}} -> {:ok, pid}
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
