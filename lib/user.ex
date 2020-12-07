defmodule User do
  # use GenServer
  alias Horde.DynamicSupervisor, as: HDS
  def via(name), do: {:via, Horde.Registry, {User.Registry, name}}
  def new(name), do: HDS.start_child(Horde, child_spec(name))
  def child_spec(name), do: %{
    id: "#{__MODULE__}_#{name}",
    start: {__MODULE__, :start_link, [name]},
  }
  def start_link(name) do
    :logger.debug("Node: #{Node.self()} User: #{name}")
    case GenServer.start_link(__MODULE__, name, name: via(name)) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      error -> error
    end
  end
  def init(name) do
    # {:ok,_} = Agenda.start_link(name)
    case Agenda.new(name) do
      {:ok, _}->{:ok,name}
      error->error
    end
  end
  def name(pid) do
    GenServer.call(pid, {:name})
  end
  def handle_call({:name}, _from, name) do
    {:reply, name, name}
  end
end
