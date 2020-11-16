defmodule Chat do
  use Agent
  def get_name(key), do: {:via, Registry, {Chat.Registry, key}}
  def start(key) do
    Agent.start_link(fn -> [] end, name: get_name(key))
  end
  def find(key) do
    case Registry.lookup(User.Registry, key) do
      [{pid, _}] -> {:ok, pid}
      [] -> {:error, :not_found}
    end
  end

  def get_msgs(chat) do
    msgs = get_name(chat)
    |> Agent.get(&(&1))
    {:ok, msgs}
  end

  def send(chat, sender, msg) do
    get_name(chat)
    |> Agent.update(&(add_msg(&1, sender, msg)))
  end

  def add_msg(msgs, sender, msg) do
    List.insert_at(msgs, -1, {DateTime.utc_now(), sender, msg})
  end

  def new_chat(participants, name \\ nil) do
    if Enum.count(participants) < 2 do
      {:error, :insuficient_participants}
    else
      Chat.start(name || join_names(participants))
    end
  end

  def join_names(participants) do
    Enum.sort(participants)
    |> Enum.join(":")
  end
end
