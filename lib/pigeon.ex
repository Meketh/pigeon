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

# GOALS
# statem
# cli
# replication
# secure msgs (Task)

# VIEWS
#   register(user, pass, name \\ user) -> {:exists}
#   login(user, pass) -> {:missmatch}
#   main -> chats con unreads
#     {/new, /group, /pm} -> {:not_found}
#   chat -> last X msgs or from unread
#     {:up, :down, :page_up, :page_down, :end, :enter, :esc, :back}

defmodule Pigeon do
  def register(user, pass) do
    case User.new(user) do
      {:error, error} -> error
      {:ok, _} -> User.set_pass(user, pass)
    end
  end
  def login(_user, _pass) do
    clear()
    io_loop()
  end
  def clear(), do: IO.puts("\e[H\e[2J")
  def sarasa() do
    IO.puts("********   ********   ********")
    Process.sleep(2_000)
    sarasa()
  end
  defp io_loop() do
    IO.gets("> ")
    |> String.trim
    |> case do
      "exit" -> clear()
      text ->
        IO.puts(String.upcase text)
        io_loop()
    end
  end
end
