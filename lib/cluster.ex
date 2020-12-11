defmodule Cluster.Supervisor do
  @cluster Application.get_env(:pigeon, :cluster, Swarm)
  @replicas Application.get_env(:pigeon, :replicas, 3)
  def start_link(), do: @cluster.Supervisor.start_link()

  # def via(id), do: @cluster.Supervisor.via(id)
  def exists(id), do: Enum.any?(1..@replicas, &exists(id, &1))
  def exists(id, replica) do
    @cluster.Supervisor.whereis({id, replica}) != :not_found
  end
  def register(child_spec) do
    if exists(child_spec.id) do
      {:error, :already_exists}
    else
      for replica <- 1..@replicas do
        child_spec.id
        |> put_in({child_spec.id, replica})
        |> @cluster.Supervisor.register()
      end
      {:ok, child_spec.id}
    end
  end

  def join(group), do: @cluster.Supervisor.join(group)
  def leave(group), do: @cluster.Supervisor.leave(group)
  def emit(group, event), do: @cluster.Supervisor.emit(group, event)
end

defmodule Cluster.Distribution do
  def key_to_node(nodes, {id, 1}), do: id_to_node(nodes, id)
  def key_to_node(nodes, {id, replica}) do
    prev = id_to_node(nodes, id)
    case Enum.filter(nodes, &(&1 != prev)) do
      [] -> prev
      rest -> key_to_node(rest, {id, replica - 1})
    end
  end
  def key_to_node(nodes, key) do
    [m, i, r] = String.split(key)
    key_to_node(nodes, {{m, i}, r})
  end
  def id_to_node(nodes, id) do
    HashRing.new()
    |> HashRing.add_nodes(nodes)
    |> HashRing.key_to_node(id)
  end
end

defmodule Cluster.Agent do
  alias Cluster.Supervisor, as: CS
  defmacro __using__(_opts) do
    quote do
      use GenServer
      def start_link(id, ops \\ []) do
        GenServer.start_link(__MODULE__, id, ops)
      end
      def init(id), do: {:ok, id, {:continue, :init}}
      def handle_continue(:init, id) do
        IO.inspect id
        IO.inspect CS.join({__MODULE__, id})
        {:noreply, on_init(id)}
      end
      def on_init(id), do: {:ok, %{id: id}}
      defoverridable on_init: 1
      def child_spec(id) do
        %{id: {__MODULE__, id},
        shutdown: 10_000,
        restart: :transient,
        start: {__MODULE__, :start_link, [id]}}
      end

      # Cluster.Supervisor
      def new(id), do: CS.register(child_spec(id))
      def exists(id), do: CS.exists({__MODULE__, id})
      def emit(id, event), do: CS.emit({__MODULE__, id}, event)
      # def join(id, events) do
      #   for e <- events,
      #   do: CS.join({__MODULE__, id, e})
      # end
      # def leave(id, events) do
      #   for e <- events,
      #   do: CS.leave({__MODULE__, id, e})
      # end

      # Agent
      # def cast(id, fun, args \\ []), do: Agent.cast(via(id), __MODULE__, fun, args)
      # def handle_cast({:cast, fun}, state), do: {:noreply, run(fun, [state])}

      # def get(id, fun, args \\ []), do: Agent.get(via(id), __MODULE__, fun, args)
      # def handle_call({:get, fun}, _from, state), do: {:reply, run(fun, [state]), state}

      # def update(id, fun, args \\ []), do: Agent.update(via(id), __MODULE__, fun, args)
      # def handle_call({:update, fun}, _from, state), do: {:reply, :ok, run(fun, [state])}

      # def get_and_update(id, fun, args \\ []), do: Agent.get_and_update(via(id), __MODULE__, fun, args)
      # def handle_call({:get_and_update, fun}, _from, state) do
      #   case run(fun, [state]) do
      #     {reply, state} -> {:reply, reply, state}
      #     {reply} -> {:reply, reply, state}
      #     other -> {:stop, {:bad_return_value, other}, state}
      #   end
      # end

      # defp run({m, f, a}, extra), do: apply(m, f, extra ++ a)
      # defp run(fun, extra), do: apply(fun, extra)

      # Swarm.Callbacks / Handoff: :restart | :ignore | {:resume, handoff}
      def handle_call({:swarm, :begin_handoff}, _from, state), do: {:reply, :restart, state}
      def handle_cast({:swarm, :end_handoff, _handoff}, state), do: {:noreply, state}
      def handle_cast({:swarm, :resolve_conflict, _conflict}, state), do: {:noreply, state}
      def handle_info({:swarm, :die}, state), do: {:stop, :shutdown, state}
    end
  end
end
