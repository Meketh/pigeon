defmodule Swarm.Agent.Net.Test do
  use Test.Case, subject: Swarm.Agent
  # setup do
  #   nodes = start_nodes(3)
  #   on_exit(fn -> stop_nodes(nodes) end)
  # end

  test "replicates on different nodes" do
    nodes = start_nodes(3)
    id = :net
    assert replicate(id, []) == {:ok, id}
    assert exists(id)
    [n1, n2, n3] = Swarm.Supervisor.whereare(id) |> Enum.map(&node(&1))
    assert n1 != n2 and n2 != n3 and n3 != n1
    stop_nodes(nodes)
  end
end
# assert Node.ping(node1) == :pong
# Node.spawn(node1, Kernel, :send, [self(), :from_node_1])
# assert_receive :from_node_1
