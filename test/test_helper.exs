defmodule Test.Case do
  defmacro __using__([subject: subject]) do
    quote do
      import Util
      import Test.Case
      use ExUnit.Case
      use AssertEventually, timeout: 5_000, interval: 500
      doctest unquote(subject)
      import unquote(subject)
      def run_on(node, fun, args), do: run_on(node, unquote(subject), fun, args)
    end
  end
  def run_on(node, mod, fun, args), do: Node.spawn(node, mod, fun, args)
  def start_nodes(n) do
    nodes = LocalCluster.start_nodes("pigeon", n)
    Process.sleep(2_000)
    nodes
  end
  def stop_nodes(nodes) do
    LocalCluster.stop_nodes(nodes)
    Process.sleep(1_000)
  end
end

LocalCluster.start()
Application.ensure_all_started(:pigeon)
ExUnit.start(exclude: [:skip], capture_log: true)
# ExUnit.start(exclude: [:skip], only_test_ids: [{Swarm.Agent.Net.Test, :"survives node loss"}])
