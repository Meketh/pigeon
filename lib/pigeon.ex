defmodule Pigeon.Application do
  use Application
  def start(_type, _args) do
    Swarm.Supervisor.start_link()
  end
end
