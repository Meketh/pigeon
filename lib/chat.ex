defmodule Chat do
  use Agent
  def get_name(key), do: {:via, Registry, {Chat.Registry, key}}
  def start(key) do
    Agent.start_link(fn -> [] end, name: get_name(key))
  end
  def find(key) do
    # case Registry.lookup(User.Registry, key) do
    case Registry.lookup(Chat.Registry, key) do
      [{pid, _}] -> {:ok, pid}
      [] -> {:error, :not_found}
    end
  end

  def get_msgs(chat) do
    msgs = get_name(chat)
    |> Agent.get(&(&1))
    {:ok, msgs}
  end

  def send(chat, sender, text) do
    get_name(chat)
    |>Agent.update(&(add_msg(&1, sender, text)))
  end

  def remove(chat,text) do
    get_name(chat)
    |>Agent.update(&(delete_msg(&1, text)))
  end

  def update(chat,msg,text) do
    get_name(chat)
    |>Agent.update(&(delete_msg(&1, text)))
  end

  def add_msg(msgs, sender, text) do
    List.insert_at(msgs, -1, %{id: UUID.uuid1(), date: DateTime.utc_now(), sender: sender, message: text})
  end

  def delete_msg(msgs, msg) do
    List.delete(msgs,msg)
  end

  def update_msg(msgs, msg, text) do
    index = Enum.find_index(msgs, fn x -> x.id == msg.id end)
    List.replace_at(msgs,index,%{msg | message: text})
  end

  def new_chat(participants, name \\ nil) do
    if Enum.count(participants) < 2 do
      {:error, :insuficient_participants}
    else
      chatname = name || join_names(participants)
      {:ok,pid,chatname} =
        case Chat.start(chatname) do
        {:ok,pid} -> {:ok,pid,chatname}
        {:error, {:already_started, pid}} -> {:ok,pid,chatname}
        end
    end
  end

  def join_names(participants) do
    Enum.sort(participants)
    |> Enum.join(":")
  end
end
