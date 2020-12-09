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
    Cluster.Supervisor.start_link()
  end
end

defmodule Pigeon do
  def clear(), do: IO.puts("\e[H\e[2J")
  def login(name) do
    clear()
    loop()
  end
  defp loop() do
    IO.gets("> ")
    |> String.trim
    |> case do
      "exit" -> clear()
      text -> clear()
        IO.puts(text)
        loop()
    end
  end
end
