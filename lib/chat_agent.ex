defmodule Chat.Agent do
  use Agent
  def get_name(key), do: {:via, Registry, {Chat.Registry, key}}
  def start(chatid, admins, members) do
    Agent.start_link(fn -> %{admins: admins , messages: [], members: members} end, name: get_name(chatid))
  end

  def get_chat(key) do
    get_name(key) |> Agent.get(&(&1))
  end

  def find(key) do
    case Registry.lookup(Chat.Registry, key) do
      [] -> {:error, :room_not_found}
      [{pid, _}] ->  get_chat(key)
    end
  end

  def find(key) do
    case Registry.lookup(Chat.Registry, key) do
      [] -> {:error, :room_not_found}
      [{pid, _}] ->  get_chat(key)
    end
  end

  def get_msgs(chat) do
    msgs = get_name(chat)
    |> Agent.get(&(&1))
  end


  def register_message(chatid, sender, text) do
    get_name(chatid)
    |>Agent.update(&(Chat.Utils.add_msg(&1, sender, text)))
  end

  def remove_message(chatid,messageid) do
    get_name(chatid)
    |>Agent.update(&(Chat.Utils.delete_msg(&1, messageid)))
  end

  def update_message(chatid,messageid,new_message) do
    get_name(chatid)
    |>Agent.update(&(Chat.Utils.update_msg(&1, messageid, new_message)))
  end


  def new_chat(creator, members) do
    if Enum.count(members) < 2 do
      {:error, :insuficient_participants}
    else
      participants = [creator | members]
      admins = [creator]
      chatid = UUID.uuid3(:oid, Enum.join(participants,""))
      {:ok,pid,roomid} =
        case start(chatid,admins,participants) do
        {:ok,pid} -> {:ok,pid,chatid}
        {:error, {:already_started, pid}} -> {:ok,pid,chatid}
        end
    end
  end

  def add_admins(chatid, admin, members) do
    chat =  find(chatid)
    if Enum.member?(chat.admins,admin) && Room.Utils.members?(chat.members,members) do
      get_name(chatid)
      |> Agent.update(&(Room.Utils.add_administrators(&1, members)))
    else
      {:error, :operation_not_allowed}
    end
  end

  def remove_admins(chatid, admin, guests) do
    chat = find(chatid)
    if Enum.member?(chat.admins,admin) do
      get_name(chatid)
      |> Agent.update(&(Room.Utils.remove_administrators(&1, guests)))
    else
      {:error, :operation_not_allowed}
    end
  end

  # def join_names(participants) do
  #   Enum.sort(participants)
  #   |> Enum.join(":")
  # end
end
