defmodule Room do
  use Agent
  def get_name(key), do: {:via, Registry, {Room.Registry, key}}
  def start(key,value) do
    Agent.start_link(fn -> value end, name: get_name(key))
  end

  @spec new(atom(), String, String) :: {atom(), pid(),String}
  def new(:personal, creator, guest) do
    participants = [creator,guest]
    roomname = participants|>join_names
    {:ok, pid} = start(roomname,%{type: :personal, participants: participants})
    {:ok,pid,roomname}
  end

  @spec new(atom(), String, List) :: {atom(), pid(),String}
  def new(:group, creator, guests) do
    participants = [creator|guests]
    roomname = participants|>join_names
    {:ok, pid} = start(roomname, %{type: :group, administrators: [creator], participants: participants})
    {:ok,pid,roomname}
  end

  defp members?(list,sublist) do
    Enum.all?(sublist, &Enum.member?(list, &1))
  end
  # @spec add_admins(String, List)::atom()
  def add_admins(roomname, admin, guests) do
    room =  find(roomname)
    if Enum.member?(room.administrators,admin) && members?(room.participants,guests) do
      get_name(roomname)
      |> Agent.update(&(add_administrators(&1, guests)))
    else
      {:error, :operation_not_allowed}
    end
  end

  defp add_administrators(room, guests) do
    room|>Map.replace(:administrators,Enum.uniq(room.administrators++guests))
  end
  defp remove_administrators(room, guests) do
    room|>Map.replace(:administrators,Enum.uniq(room.administrators--guests))
  end

  def remove_admins(roomname, admin, guests) do
    room = find(roomname)
    if Enum.member?(room.administrators,admin) do
      get_name(roomname)
      |> Agent.update(&(remove_administrators(&1, guests)))
    else
      {:error, :operation_not_allowed}
    end
  end

  def update(key,value) do
    # get_name(key)
    # |> Agent.update(&(update_pid(&1, value)))
  end


  defp join_names(participants) do
    Enum.sort(participants)
    |> Enum.join(":")
  end

  defp get_room(key) do
    get_name(key) |> Agent.get(&(&1))
  end

  def find(key) do
    case Registry.lookup(Room.Registry, key) do
      [] -> {:error, :room_not_found}
      [{pid, _}] -> get_room(key)
    end
  end
end
