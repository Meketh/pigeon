defmodule Test.Helper do
  import Horde.Cluster
  def wait_nodes do
    Process.sleep(100)
    nodes = length(Node.list())
    if nodes > 0
    and nodes == members(Horde)
    and nodes == members(User.Registry)
    and nodes == members(Agenda.Registry)
    do
      wait_nodes()
    end
  end
end
Test.Helper.wait_nodes()
ExUnit.start()
