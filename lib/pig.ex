defmodule Pig do
  use GenServer
  def start do
     GenServer.start(Pig, %{})
  end

  # def login(key) do
  #   {:ok,server} = case Session.find(key) do
  #     {:ok, userpid} -> {:ok,userpid}
  #     {:error, {:already_started, userpid}} -> {:ok,userpid}
  #     {:error, :session_not_found} -> start |> {Session.update(key)
  #     {:error, :user_not_found} -> Session.start(key)|>elem(0)
  #     _ -> {:error, :not_found}
  #   end
  #   {:ok,server}
  # end

  def send(pid_from,pid_to,msg) do
    GenServer.call(pid_to, {:send, msg, pid_from})
  end

  def login(pid,nickname) do
    GenServer.call(pid, {:login, nickname})
  end

  def chats(recipient) do

  end

  # Callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_call({:send, msg, pidfrom}, _from, state) do
    GenServer.call(pidfrom, {:get_user_id})
    |>
    # process_send()
    IO.inspect(pidfrom)
    {:reply,msg, state|>Map.replace(:msgs,[msg|state.msgs])}
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, Map.fetch!(state, key), state}
  end

  def handle_call({:msg, value}, _from, state) do
    {:reply, value, state}
  end

  def handle_call({:login, user_id}, _from, state) do
    {:ok,user_pid} = process_login(user_id)
    IO.puts()
    {:reply, {:ok,user_pid}, %{user_id: user_id,msg: []}}
  end

  def process_login(userid) do
    {:ok,userpid} = case Session.find(userid) do
      {:ok, userpid} -> {:ok,userpid}
      {:error, :session_not_found} -> {Session.update(userid,self()),self()}
      {:error, :user_not_found} -> {Session.start(userid, self()),self()}
      _ -> {:error, :not_found}
    end
  end
  defp process_send( pid_from, pid_to, msg) do
    # {:ok,sender_session} = Session.find(sender)
    # {:ok,receiver_session} = Session.find(receiver)
    # {:ok,pid,roomname} = Room.new(:personal,sender,receiver)
    {:ok,chat_pid,chat_key} = Chat.new_chat([sender,receiver],nil)
    :ok = Chat.send(chat_key,sender,msg)
    GenServer.call(receiver_session, {:msg, "#{sender}: #{msg}"})
  catch error, kind ->
    kind|>elem(1)
  end
end
