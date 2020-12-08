# defmodule Test.Helper do
#   import Horde.Cluster
#   def wait_nodes do
#     Process.sleep(100)
#     nodes = length(Node.list())
#     IO.inspect(Pigeon.Application.horde())
#     full? = Pigeon.Application.horde()
#       |> Enum.map(&elem(&1, 0))
#       |> Enum.all?(&(members(&1) == nodes))
#     unless full?, do: wait_nodes()
#   end
# end
# Test.Helper.wait_nodes()
# Process.sleep(Application.get_env(:swarm, :sync_nodes_timeout, 10_000))
# Process.sleep(3_000)
ExUnit.start()
