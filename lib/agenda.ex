defmodule Agenda do
  use Agent
  use Swarm.Supervisor
  def start_link(_name) do
    Agent.start_link(fn -> %{} end)
  end
  def add(name, contact) do
    Agent.update(via(name), &Map.put(&1, contact, 0))
  end
  def get(name) do
    Agent.get(via(name), & &1)
  end
end
