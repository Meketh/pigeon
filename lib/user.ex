defmodule User do
  # use GenServer
  alias Horde.DynamicSupervisor, as: HDS
  def via(name), do: {:via, Horde.Registry, {User.Registry, name}}

  def new(name,node), do: HDS.start_child(Horde, child_spec(name,node))

  def new(name), do: User.new(name,Node.self())

  def child_spec(name, node),
    do: %{
      id: "#{__MODULE__}_#{name}_#{node}",
      start: {__MODULE__, :start_link, [name]}
    }

  def get_node(pid) do
    GenServer.call(pid, {:get_node})
  end

  def handle_call({:get_node}, _from, state) do
    {:reply, Node.self(),state}
  end

  def dnew(name) do
    Pigeon.Process.dnew(name,Horde,User)
  end
  # def dnew(name) do
  #   nodes = Enum.map(Node.list(), fn n -> "#{n}" end)
  #   nodes = Enum.concat(nodes,["#{Node.self()}"])

  #   :logger.debug("NODOS DNEW: #{inspect nodes}")

  #   :logger.debug("CHILDREN DNEW: #{inspect HDS.which_children(Horde)}")

  #   children_pids = Enum.map(HDS.which_children(Horde), fn {_, pid, _, _} -> pid end)

  #   children_pids = Enum.filter(children_pids, fn  pid -> User.name(pid)==name  end)

  #   :logger.debug("IDS DNEW: #{inspect children_pids}")

  #   children_nodes = Enum.map(children_pids, fn c -> User.get_node(c) end)

  #   max_instances = 2

  #   if(length(children_nodes) < max_instances) do
  #     nodes_to_choose = Enum.filter(nodes, fn n -> !Enum.member?(children_nodes, n) end)
  #     nodes_choosed = Enum.take_random(nodes_to_choose, max_instances - length(children_nodes))

  #     Enum.each(nodes_choosed, fn n -> User.new(name, n) end)
  #   end

  #   Enum.map(children_pids,fn c->{:ok,c} end)
  # end

  def start_link(name) do
    :logger.debug("Node: #{Node.self()} User: #{name}")

    case GenServer.start_link(__MODULE__, name, name: via(name)) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      error -> error
    end
  end

  def init(name) do
    {:ok, name}
    # case Agenda.new(name) do
    #   {:ok, _}->{:ok,name}
    #   error->error
    # end
  end

  def name(pid) do
    GenServer.call(pid, {:name})
  end

  def handle_call({:name}, _from, name) do
    {:reply, name, name}
  end
end
