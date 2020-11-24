defmodule Session do
  use Agent
  def get_name(key), do: {:via, Registry, {Session.Registry, key}}
  def start(key) do
    Agent.start_link(fn -> [] end, name: get_name(key))
  end
  def update(key,value) do
    get_name(key)
    |> Agent.update(&(update_pid(&1, value)))
  end

  def update_pid(oldpid, newpid) do
    IO.inspect(oldpid)
    if (is_pid(oldpid)) do
      Process.exit(oldpid,:kill)
    end
    newpid
  end

  defp get_active(key) do
    pid = get_name(key) |> Agent.get(&(&1));
    if is_pid(pid) && !Process.alive?(pid) do
      pid = []
      :ok = update(key,pid)
    end
    if pid == [] do
      {:error,:session_not_found}
    else
      {:ok,pid}
    end
  end

  def find(key) do
    case Registry.lookup(Session.Registry, key) do
      [] -> {:error, :user_not_found}
      [{pid, _}] -> get_active(key)
    end
  end
end
