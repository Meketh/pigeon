defmodule Room do
  use GenServer
  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def new_group(pid,creator,guests) do
    GenServer.call(pid, {:new_room,:group,creator,guests})
  end

  def new_group(pid,creator,guest) do
    GenServer.call(pid, {:new_room,:personal,creator,guest})
  end
  # Callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_call({:new_room, :group, creator, guests}, _from, state) do
    participants = [creator,guests]
    roomname = UUID.uuid4()
    {:ok, pid} = Room.Agent.start(roomname,%{type: :personal, participants: participants})
    {:reply,"Se ha creado la sala #{roomname} con los participantes [#{participants}]", %{roomname: roomname}}
  end

  def handle_call({:new_room, :personal, creator, guest}, _from, state) do
    participants = [creator,guest]
    roomname = UUID.uuid3(:oid, participants)
    {:reply, :hola, state}
  end

  # @spec new(atom(), String, String) :: {atom(), pid(),String}
  # def new(:personal, creator, guest) do

  # end

  # @spec new(atom(), String, List) :: {atom(), pid(),String}
  # def new(:group, creator, guests) do
  #   participants = [creator|guests]
  #   roomname = participants|>join_names
  #   {:ok, pid} = start(roomname, %{type: :group, administrators: [creator], participants: participants})
  #   {:ok,pid,roomname}
  # end
end
