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

# :ok = LocalCluster.start()
Application.ensure_all_started(:pigeon)
ExUnit.start()
# defmodule MyTest do
#   use ExUnit.Case
#   test "spawning tasks on a cluster" do
#     nodes = LocalCluster.start_nodes(:spawn, 3, [
#       files: [
#         __ENV__.file
#       ]
#     ])
#     [node1, node2, node3] = nodes
#     assert Node.ping(node1) == :pong
#     assert Node.ping(node2) == :pong
#     assert Node.ping(node3) == :pong
#     caller = self()
#     Node.spawn(node1, fn->send(caller, :from_node_1)end)
#     Node.spawn(node2, fn->send(caller, :from_node_2)end)
#     Node.spawn(node3, fn->send(caller, :from_node_3)end)
#     assert_receive :from_node_1
#     assert_receive :from_node_2
#     assert_receive :from_node_3
#   end
# end
