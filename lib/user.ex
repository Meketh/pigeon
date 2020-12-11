defmodule User do
  use GenServer
  def start_link(state) do
     GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def send(pid,chatid,msg) do
    GenServer.cast(pid, {:send, msg, chatid})
  end

  def login(pid,userid) do
    GenServer.cast(pid, {:login,userid})
  end

  def get_user_id(pid) do
    GenServer.call(pid, {:get_user_id})
  end

  # Callbacks

  def init(state) do
    {:ok, state}
  end

  defp handle_non_stored_chat(msg, chatid, state) do
    {:ok,pid} = Chat.start_link(chatid)
    :ok = GenServer.cast(pid, {:send, msg, state.userid})
    {:noreply, %{state | chats: List.insert_at(state.chats, -1, %{id: chatid, pid: pid})}}
  end

  defp handle_stored_chat(chat,msg, state) do
    :ok = GenServer.cast(chat.pid, {:send, msg, state.userid})
    {:noreply, state}
  end

  def handle_cast({:send, msg, chatid}, state) do
      case Enum.find(state.chats, fn chat -> chat.id == chatid  end) do
        nil -> handle_non_stored_chat(msg, chatid, state)
        chat -> handle_stored_chat(chat, msg, state)
      end
  end

  def handle_call({:get_chats}, _from, state) do
    {:reply, state.chats ,state}
  end

  def handle_cast({:add_admins, chatid, guests}, state) do
    chat = Enum.find(state.chats, fn chat -> chat.id == chatid  end)
    GenServer.cast(chat.pid, {:add_admins, state.userid, guests})
    {:noreply, state}
  end

  def handle_cast({:remove_admins, chatid, guests}, state) do
    chat = Enum.find(state.chats, fn chat -> chat.id == chatid  end)
    GenServer.cast(chat.pid, {:remove_admins, state.userid, guests})
    {:noreply, state}
  end

  def handle_call({:get_state}, _from, state) do
    {:reply, state ,state}
  end

  def handle_cast({:notify, value}, state) do
    IO.puts("Mensaje recibido: #{value} ")
    {:noreply, state}
  end

  def handle_cast({:login, userid}, state) do
    {:ok,user_pid} = process_login(userid)
    {:noreply, %{userid: userid,chats: []}}
  end

  def process_login(userid) do
    {:ok,userpid} = case User.Agent.find(userid) do
      {:ok, userpid} -> {:ok,userpid}
      {:error, :session_not_found} -> {User.Agent.update(userid,self()),self()}
      {:error, :user_not_found} -> {User.Agent.start(userid, self())|>elem(0),self()}
      _ -> {:error, :not_found}
    end
  end
end
