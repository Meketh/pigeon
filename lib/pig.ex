defmodule Pig do
  use GenServer
  # def start do
  #   GenServer.start(Pig, %{})
  # end

  def login(key) do
    {:ok,server} = GenServer.start(Pig, %{})
    {:ok, userpid} =
    case Session.find(key) do
      {:ok, userpid} -> {:ok, userpid}
      {:error, {:already_started, userpid}} -> {:ok, userpid}
      {:error, :session_not_found} -> {:ok,[]}
      {:error, :user_not_found} -> Session.start(key)
      _ -> {:error, :not_found}
    end
    {:ok,server} = {Session.update(key,server),server}
  end

  def send(sender, receiver, msg) do
    {:ok,sender_session} = Session.find(sender)
    {:ok,receiver_session} = Session.find(receiver)
    {:ok,chat_pid,chat_key} = Chat.new_chat([sender,receiver],nil)
    :ok = Chat.send(chat_key,sender,msg)
    GenServer.call(receiver_session, {:msg, "#{sender}: #{msg}"})
  catch error, kind ->
    kind|>elem(1)
  end

  def messages(recipient) do
    # Chat.get_msgs()
  end

  def chats(recipient) do

  end

  def get(server, key) do
    GenServer.call(server, {:get, key})
  end

  # Callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, Map.fetch!(state, key), state}
  end

  def handle_call({:msg, value}, _from, state) do
    {:reply, value, state}
  end
end
