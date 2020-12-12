defmodule Pigeon.Application do
  use Application
  @interval Application.get_env(:peerage, :interval, 1) * 1000
  def wait_nodes(prev) do
    Process.sleep(@interval)
    nodes = length(Node.list())

    if prev == nodes do
      Process.sleep(@interval)
    else
      wait_nodes(nodes)
    end
  end

  def start(_type, _args) do
    wait_nodes(0)

    # Supervisor.start_link(
    #   [
    #     {Swarm.Supervisor, []}
    #   ],
    #   strategy: :one_for_one,
    #   name: Pigeon.Supervisor
    # )

    Swarm.Supervisor.start_link()
  end
end
