defmodule Agenda do
  # use Agent
  alias Horde.DynamicSupervisor, as: HDS

  def via(name), do: {:via, Horde.Registry, {Agenda.Registry, name}}
  # def via(name) do
  #   case Horde.Registry.lookup(Agenda.Registry, name) do
  #     [{pid, _}] -> pid
  #     [] -> {:error, :create_failed}
  #   end
  # end
  def new(name), do: HDS.start_child(Agenda.Supervisor, child_spec(name))

  def child_spec(name), do: %{
    id: "#{__MODULE__}_#{name}_#{Node.self()}",
    start: {__MODULE__, :start_link, [name]},
  }

  def start_link(name) do
    :logger.debug("Node: #{Node.self()} Agenda: #{name}")
    # {:ok, crdt1} = DeltaCrdt.start_link(DeltaCrdt.AWLWWMap)
    # Horde.Registry.register(Agenda.Registry, name, crdt1)
    # {:ok, crdt1}
    opts = [name: via(name)]

    DeltaCrdt.start_link(DeltaCrdt.AWLWWMap,opts)

    # Agent.start_link(fn -> %{} end, name: via(name))

    # case GenServer.start_link(__MODULE__, name, name: via(name)) do
    #   {:ok, pid} -> {:ok, pid}
    #   {:error, {:already_started, pid}} -> {:ok, pid}
    #   error -> error
    # end
  end
  # def init(name) do
  #   {:ok, name}
  # end
  @spec add(atom | pid | {atom, any} | {:via, atom, any}, any) :: :ok
  def add(pid, name) do
    DeltaCrdt.mutate(pid, :add, [name, 0])
    # Agent.update(pid, &Map.put(&1, name, 0))
    # Agent.update(pid, &Map.put(&1, name, 0))
  end
  def get(pid) do
    DeltaCrdt.read(pid)
    # Agent.get(pid, & &1)
  end
end
