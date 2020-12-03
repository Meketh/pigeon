defmodule User do
  use GenServer
  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def send(pid_from,pid_to,msg) do
    GenServer.call(pid_to, {:send, msg, pid_from})
  end

  def login(pid,nickname) do
    GenServer.call(pid, {:login, nickname})
  end

  def get_user_id(pid) do
    GenServer.call(pid, {:get_user_id})
  end

  # Callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_call({:send, msg, pid_receiver}, _from, state) do
    #{:ok, user_id_receiver} = GenServer.call(pid_receiver, {:get_user_id})

    # process_send(self(), state.user_id, pid_receiver, user_id_receiver, msg)
    {:reply,msg, state|>Map.replace(:msgs,[msg|state.msgs])}
  end

  def handle_call({:get_user_id}, _from, state) do
    {:reply, state.user_id,state}
  end

  def handle_call({:msg, value}, _from, state) do
    {:reply, value, state}
  end

  def handle_call({:login, user_id}, _from, state) do
    {:ok,user_pid} = process_login(user_id)
    {:reply, {:ok,user_pid}, %{user_id: user_id,msg: []}}
  end

  def process_login(userid) do
    {:ok,userpid} = case Session.find(userid) do
      {:ok, userpid} -> {:ok,userpid}
      {:error, :session_not_found} -> {Session.update(userid,self()),self()}
      {:error, :user_not_found} -> {Session.start(userid, self())|>elem(0),self()}
      _ -> {:error, :not_found}
    end
  end
  defp process_send( pid_sender,user_id_sender, pid_receiver, user_id_receiver, msg) do
    # {:ok,sender_session} = Session.find(sender)
    # {:ok,receiver_session} = Session.find(receiver)
    # {:ok,pid,roomname} = Room.new(:personal,sender,receiver)
    # Validacion de pids, users etc
    # {:ok,chat_pid,chat_key} = Chat.new_chat([sender,receiver],nil)
    # :ok = Chat.send(chat_key,sender,msg)
    # GenServer.call(receiver_session, {:msg, "#{sender}: #{msg}"})
  # catch error, kind ->
  #   kind|>elem(1)
  end
end
