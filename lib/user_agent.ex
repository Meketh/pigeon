defmodule User.Agent do
  use Agent
  def get_name(userid), do: {:via, Registry, {User.Registry, userid}}
  def start(userid, pid  \\ []) do
    Agent.start_link(fn -> pid end, name: get_name(userid))
  end
  def update(userid,value) do
    get_name(userid)
    |> Agent.update(&(update_pid(&1, value)))
  end

  def update_pid(oldpid, newpid) do
    IO.inspect(oldpid)
    if (is_pid(oldpid)) do
      Process.exit(oldpid,:kill)
    end
    newpid
  end

  defp get_active(userid) do
    pid = get_name(userid) |> Agent.get(&(&1));
    if is_pid(pid) && !Process.alive?(pid) do
      pid = []
      :ok = update(userid,pid)
    end
    if pid == [] do
      {:error,:session_not_found}
    else
      {:ok,pid}
    end
  end

  def find(userid) do
    case Registry.lookup(User.Registry, userid) do
      [] -> {:error, :user_not_found}
      [{pid, _}] -> get_active(userid)
    end
  end
end
