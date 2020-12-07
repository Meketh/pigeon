defmodule Agenda do
  # use Agent
  alias Horde.DynamicSupervisor, as: HDS
  def via(name), do: {:via, Horde.Registry, {Agenda.Registry, name}}
  def new(name), do: HDS.start_child(Horde, child_spec(name))
  def child_spec(name), do: %{
    id: "#{__MODULE__}_#{name}",
    start: {__MODULE__, :start_link, [name]},
  }
  def start_link(name) do
    :logger.debug("Node: #{Node.self()} Agenda: #{name}")
    case GenServer.start_link(__MODULE__, name, name: via(name)) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      error -> error
    end
  end
  def init(name) do
    {:ok, name}
  end
  def add(pid, name) do
    Agent.update(pid, &Map.put(&1, name, 0))
  end
  def get(pid) do
    Agent.get(pid, & &1)
  end
end
