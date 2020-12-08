defmodule Pigeon.Application do
  use Application
  def start(_type, _args) do
    wait_nodes(0)
    Supervisor.start_link([Swarm.Supervisor], [strategy: :one_for_one])
  end
  def wait_nodes(prev) do
    interval = Application.get_env(:peerage, :interval, 1)
    Process.sleep(interval * 1000)
    nodes = length(Node.list())
    :logger.debug("Nodes: #{prev}/#{nodes}")
    if prev == nodes do
      Process.sleep(interval * 1000)
    else
      wait_nodes(nodes)
    end
  end
end

# defmodule Pigeon.Application do
#   use Application
#   def horde(), do: User.horde()
#   def start(_type, _args) do
#     Supervisor.start_link(horde(), [name: Pigeon.Supervisor, strategy: :one_for_one])
#   end
# end
