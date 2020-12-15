defmodule Swarm.Agent.Net.Test do
  use Test.Case, subject: Swarm.Agent

  @tag cluster: true
  test "replicates on different nodes" do
    id = :replicates
    nodes = start_nodes(2)
    assert replicate(id, []) == {:ok, id}
    assert exists(id)
    eventually assert different_nodes(id)
    dereplicate(id)
    stop_nodes(nodes)
  end

  @tag cluster: true
  test "eventually converges" do
    id = :converges
    nodes = start_nodes(2)
    assert replicate(id, [:state]) == {:ok, id}
    assert set(id, [:state, :key], :value) == :ok
    assert_eventually converges(id, [:state, :key], :value)
    dereplicate(id)
    stop_nodes(nodes)
  end

  @tag cluster: true
  test "survives node loss" do
    id = :survives
    # [n1, n2] = start_nodes(2)
    nodes = start_nodes(2)
    assert replicate(id, [:state]) == {:ok, id}
    assert_eventually different_nodes(id)
    assert set(id, [:state, :key], :value) == :ok
    assert_eventually converges(id, [:state, :key], :value)

    # stop_nodes([n1])
    # assert_eventually converges(id, [:state, :key], :value)
    # stop_nodes([n2])
    # assert_eventually same_node(id)
    # assert_eventually converges(id, [:state, :key], :value)

    stop_nodes(nodes)
    assert_eventually same_node(id)
    assert_eventually converges(id, [:state, :key], :value)

    [n1, n2, n3, n4] = nodes = start_nodes(4)
    [n1, n2, n3, n4] |> Util.debug

    assert_eventually different_nodes(id)
    assert_eventually get_all(id, [:state, :key]) == [:value, :value, :value]
    assert_eventually converges(id, [:state, :key], :value)
    dereplicate(id)
    stop_nodes(nodes)
  end

  @tag cluster: true
  test "resolves conflicts on partition heal" do
  end

  def converges(id, path, value) do
    get_all(id, path) |> Util.debug |> Enum.all?(&(&1 == value))
  end

  def same_node(id) do
    [n1, n2, n3] = id
    |> Swarm.Supervisor.whereare()
    |> Util.debug
    |> Enum.map(&(case &1 do
      pid when is_pid(pid) -> node(&1)
      other -> other
    end))
    |> Util.debug
    n1 == n2 and n2 == n3
  end

  def different_nodes(id) do
    [n1, n2, n3] = id
    |> Swarm.Supervisor.whereare()
    |> Enum.map(&node(&1))
    n1 != n2 and n2 != n3 and n3 != n1
  end
end
# assert Node.ping(node1) == :pong
# Node.spawn(node1, Kernel, :send, [self(), :from_node_1])
# assert_receive :from_node_1
