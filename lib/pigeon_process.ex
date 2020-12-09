defmodule Pigeon.Process do
  # use GenServer
  alias Horde.DynamicSupervisor, as: HDS
  def generic_new(name, node,supervisor,module), do: HDS.start_child(supervisor, child_spec(name, node,module))

  def child_spec(name, node,module),
    do: %{
      id: "#{module}_#{name}_#{node}",
      start: {module, :start_link, [name]}
    }

  @spec get_node(atom | pid | {atom, any} | {:via, atom, any}) :: any
  def get_node(pid) do
    GenServer.call(pid, {:get_node})
  end

  def handle_call({:get_node}, _from, state) do
    {:reply, Node.self(),state}
  end

  def get_max_instances() do
    2
  end

  def dnew(name,supervisor,module) do
    nodes = Enum.map(Node.list(), fn n -> "#{n}" end)
    nodes = Enum.concat(nodes,["#{Node.self()}"])

    :logger.debug("NODOS DNEW: #{inspect nodes}")

    :logger.debug("CHILDREN DNEW: #{inspect HDS.which_children(supervisor)}")

    children_pids = Enum.map(HDS.which_children(supervisor), fn {_, pid, _, _} -> pid end)

    children_pids = Enum.filter(children_pids, fn  pid -> module.name(pid)==name  end)

    :logger.debug("IDS DNEW: #{inspect children_pids}")

    children_nodes = Enum.map(children_pids, fn c -> Pigeon.Process.get_node(c) end)

    max_instances = Pigeon.Process.get_max_instances()

    if(length(children_nodes) < max_instances) do
      nodes_to_choose = Enum.filter(nodes, fn n -> !Enum.member?(children_nodes, n) end)
      nodes_choosed = Enum.take_random(nodes_to_choose, max_instances - length(children_nodes))

      Enum.each(nodes_choosed, fn n -> Pigeon.Process.generic_new(name, n,supervisor,module) end)
    end

    Enum.map(children_pids,fn c->{:ok,c} end)
  end

end
