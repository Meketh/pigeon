defmodule Agenda do
  use Agent
  alias Horde.DynamicSupervisor, as: HDS

  @spec via(any) :: {:via, Horde.Registry, {Agenda.Registry, any}}
  def via(name), do: {:via, Horde.Registry, {Agenda.Registry, name}}
  def new(name), do: HDS.start_child(Agenda.Supervisor, child_spec(name))

  def child_spec(name), do: %{
    id: "#{__MODULE__}_#{name}_#{Node.self()}",
    start: {__MODULE__, :start_link, [name]},
  }

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, any}
  def start_link(name) do
    :logger.debug("Node: #{Node.self()} Agenda: #{name}")
    Agent.start_link(fn -> %{} end, name: via(name))

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
    Agent.update(pid, &Map.put(&1, name, 0))
  end
  def get(pid) do
    Agent.get(pid, & &1)
  end
end
