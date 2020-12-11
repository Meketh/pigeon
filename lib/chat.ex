defmodule Chat do
  use GenServer
  def start_link(chatid) do
    GenServer.start_link(__MODULE__, chatid, name: String.to_atom(chatid))
  end

  # Callbacks
  def init(state) do
    {:ok, state}
  end

  def handle_cast({:send, msg, userid}, chatid) do
    Chat.Agent.register_message(chatid,userid,msg)
    for member <- Chat.Agent.find(chatid).members do
      GenServer.cast(User.Agent.find(member)|>elem(1), {:notify, msg})
    end
    {:noreply, chatid}
  end

  def handle_call({:get}, _from, chatid) do
    {:reply, Chat.Agent.find(chatid),chatid}
  end

  def handle_cast({:delete_message, messageid},chatid) do
    Chat.Agent.remove_message(chatid,messageid)
    {:noreply, chatid}
  end

  def handle_cast({:update_message, messageid, message},chatid) do
    Chat.Agent.update_message(chatid,messageid,message)
    {:noreply, chatid}
  end

  def handle_cast({:add_admins, admin, guests},chatid) do
    Chat.Agent.add_admins(chatid,admin,guests)
    {:noreply, chatid}
  end

  def handle_cast({:remove_admins, admin, guests},chatid) do
    Chat.Agent.remove_admins(chatid,admin,guests)
    {:noreply, chatid}
  end
end
