defmodule Test.Helper do
  import Horde.Cluster
  def wait_nodes do
    Process.sleep(10000)
    nodes = length(Node.list())
    if nodes > 0
    and nodes == members(Horde)
    and nodes == members(User.Registry)
    do
      wait_nodes()
    end
  end
end
Test.Helper.wait_nodes()
ExUnit.start()
