defmodule User do
  # use GenServer
  alias Pigeon.Process, as: PP
  def via(name), do: {:via, Horde.Registry, {User.Registry, name}}

  def new(name,node), do: PP.generic_new(name, node,Horde,User)

  def new(name), do: User.new(name,Node.self())

  # def child_spec(name, node),
  #   do: %{
  #     id: "#{__MODULE__}_#{name}_#{node}",
  #     start: {__MODULE__, :start_link, [name]}
  #   }

  def get_node(pid) do
    GenServer.call(pid, {:get_node})
  end

  def handle_call({:get_node}, _from, state) do
    {:reply, Node.self(),state}
  end

  def dnew(name) do
    PP.dnew(name,Horde,User,User.Registry)
  end

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
