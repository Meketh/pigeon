defmodule Swarm.Agent.Test do
  use Test.Case, subject: Swarm.Agent

  test "replicates" do
    id = :replicates
    assert replicate(id) == {:ok, id}
    assert read(id) == %{}
    unreplicate(id)
  end

  test "write" do
    id = :write
    assert replicate(id) == {:ok, id}
    assert write(id, :x, 333) == :ok
    assert write(id, :y, 666) == :ok
    assert write(id, :z, 999) == :ok
    assert read(id) == %{x: 333, y: 666, z: 999}
    unreplicate(id)
  end

  test "remove" do
    id = :remove
    assert replicate(id) == {:ok, id}
    assert write(id, :x, 333) == :ok
    assert write(id, :y, 666) == :ok
    assert write(id, :z, 999) == :ok
    assert read(id) == %{x: 333, y: 666, z: 999}
    assert remove(id, :z) == :ok
    assert read(id) == %{x: 333, y: 666}
    assert remove(id, :y) == :ok
    assert read(id) == %{x: 333}
    assert remove(id, :x) == :ok
    assert read(id) == %{}
    unreplicate(id)
  end

  test "write_async" do
    id = :write
    assert replicate(id) == {:ok, id}
    assert write_async(id, :x, 333) == :ok
    assert write_async(id, :y, 666) == :ok
    assert write_async(id, :z, 999) == :ok
    assert_eventually read(id) == %{x: 333, y: 666, z: 999}
    unreplicate(id)
  end

  test "remove_async" do
    id = :remove
    assert replicate(id) == {:ok, id}
    assert write(id, :x, 333) == :ok
    assert write(id, :y, 666) == :ok
    assert write(id, :z, 999) == :ok
    assert read(id) == %{x: 333, y: 666, z: 999}
    assert remove_async(id, :z) == :ok
    assert_eventually read(id) == %{x: 333, y: 666}
    assert remove_async(id, :y) == :ok
    assert_eventually read(id) == %{x: 333}
    assert remove_async(id, :x) == :ok
    assert_eventually read(id) == %{}
    unreplicate(id)
  end

  # @tag cluster: true
  # test "replicates on different nodes" do
  #   id = :replicates
  #   nodes = start_nodes(2)
  #   assert replicate(id, []) == {:ok, id}
  #   assert_eventually different_nodes(id)
  #   unreplicate(id)
  #   stop_nodes(nodes)
  # end

  # @tag cluster: true
  # test "eventually converges" do
  #   id = :converges
  #   nodes = start_nodes(2)
  #   assert replicate(id, [:state]) == {:ok, id}
  #   assert set(id, [:state, :key], :value) == :ok
  #   assert_eventually converges(id, [:state, :key], :value)
  #   unreplicate(id)
  #   stop_nodes(nodes)
  # end

  # @tag cluster: true
  # test "survives node loss" do
  #   id = :survives
  #   [n1, n2] = start_nodes(2)
  #   # nodes = start_nodes(2)
  #   assert replicate(id, [:state]) == {:ok, id}
  #   assert_eventually different_nodes(id)
  #   assert set(id, [:state, :key], :value) == :ok
  #   assert_eventually converges(id, [:state, :key], :value)

  #   stop_nodes([n1])
  #   assert_eventually converges(id, [:state, :key], :value)
  #   stop_nodes([n2])
  #   assert_eventually converges(id, [:state, :key], :value)
  #   assert_eventually same_node(id)

  #   # stop_nodes(nodes)
  #   # assert_eventually same_node(id)
  #   # assert_eventually converges(id, [:state, :key], :value)

  #   [n1, n2, n3, n4] = nodes = start_nodes(4)
  #   [n1, n2, n3, n4] |> Util.debug

  #   assert_eventually different_nodes(id)
  #   assert_eventually get_all(id, [:state, :key]) == [:value, :value, :value]
  #   assert_eventually converges(id, [:state, :key], :value)
  #   unreplicate(id)
  #   stop_nodes(nodes)
  # end

  # @tag cluster: true
  # test "resolves conflicts on partition heal" do
  # end

  # defp converges(id, path, value) do
  #   get_all(id, path) |> Util.debug |> Enum.all?(&(&1 == value))
  # end

  # defp same_node(id) do
  #   [n1, n2, n3] = id
  #   |> Swarm.Supervisor.whereare()
  #   |> Util.debug
  #   |> Enum.map(&get_node/1)
  #   |> Util.debug
  #   n1 == n2 and n2 == n3
  # end

  # defp different_nodes(id) do
  #   [n1, n2, n3] = id
  #   |> Swarm.Supervisor.whereare()
  #   |> Enum.map(&get_node/1)
  #   n1 != n2 and n2 != n3 and n3 != n1
  # end

  # defp get_node(pid) when is_pid(pid), do: node(pid)
  # defp get_node(pid), do: pid
end
# assert Node.ping(node1) == :pong
# Node.spawn(node1, Kernel, :send, [self(), :from_node_1])
# assert_receive :from_node_1
