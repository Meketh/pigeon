defmodule Chat do
  alias Swarm.Agent, as: SA
  alias Swarm.Supervisor, as: SS

  defstruct [id: Nanoid.generate(), role: :admin, last_seen: 0]
  defmodule Msg do
    defstruct [:id, :sender, :text, :created]
    def new(sender, text) do
      %Msg{id: Nanoid.generate(),
        sender: sender, text: text,
        created: :os.system_time}
    end
  end
  defmodule Listener do
    use GenServer
    def start_link(chat) do
      id = {chat.id, Nanoid.generate()}
      SS.register(%{id: id,
        start: {GenServer, :start_link, [Listener, [chat.id]]}})
      id
    end
    def init(chat_id) do
      {:ok, chat_id, {:continue, :init}}
    end
    def handle_continue(:init, chat_id) do
      Swarm.join(chat_id, self())
      {:noreply, chat_id}
    end
    def handle_info(msg, chat_id) do
      IO.inspect{chat_id, msg}
      {:noreply, chat_id}
    end
  end
  def listen(chat), do: Listener.start_link(chat)

  def pm_id(a, b), do: Enum.sort([a, b])
  def pm(a, b) do
    cond do
      not User.exists(a) -> {:error, {:user_not_found, a}}
      not User.exists(b) -> {:error, {:user_not_found, b}}
      true ->
        id = pm_id(a, b)
        chat = %Chat{id: id, role: :member, last_seen: :os.system_time}
        unless exists(id) do
          new(id)
          name(chat, id)
          join(chat, b)
        end
        join(chat, a)
        chat
    end
  end
  def new(name, admin) do
    id = Nanoid.generate()
    new(id)
    chat = %Chat{id: id}
    name(chat, name)
    join(chat, admin)
  end
  def exists(id) do
    SS.replicated({Chat, id, :state})
    and SS.replicated({Chat, id, :members})
    and SS.replicated({Chat, id, :msgs})
  end

  def add(chat, user, role \\ :member)
  def add(%{role: role}, _, _) when role != :admin, do: {:error, :not_admin}
  def add(%Chat{id: id}, user, role) do
    join(%Chat{id: id, role: role}, user)
  end

  def remove(%{role: role}, _, _) when role != :admin, do: {:error, :not_admin}
  def remove(%Chat{id: id}, user) do
    User.leave(user, id)
    SA.remove({Chat, id, :members}, user)
  end

  def name(%Chat{id: id}), do: SA.read({Chat, id, :state}, [:name])
  def name(%Chat{id: id}, name), do: SA.write({Chat, id, :state}, :name, name)
  def members(%Chat{id: id}), do: SA.read({Chat, id, :members})
  def msgs(%Chat{id: id}), do: SA.read({Chat, id, :msgs})
  def msgs(chat, from, to \\ :infinity) do
    Enum.map(msgs(chat), &elem(&1, 1))
    |> Enum.filter(&(from <= &1.created and &1.created <= to))
  end
  def count(chat, from, to \\ :infinity) do
    msgs(chat, from, to) |> Enum.count()
  end
  def past_msgs(chat, from, count) do
    Enum.map(msgs(chat), &elem(&1, 1))
    |> Enum.filter(&(&1.created <= from))
    |> Enum.sort(&(&1.created > &2.created))
    |> Enum.take(count)
  end

  def msg(%Chat{id: id}, sender, text) do
    msg = Msg.new(sender, text)
    SA.write({Chat, id, :msgs}, msg.id, msg)
    Swarm.publish(id, {:msg, msg})
  end
  def mod(%Chat{id: id}, msg, text) do
    SA.update({Chat, id, :msgs}, [msg.id], fn m ->
      if m.sender == msg.sender do
        put_in(m.text, text)
        Swarm.publish(id, {:mod, msg})
      else m end
    end)
  end
  def del(%Chat{id: id}, msg) do
    m = SA.read({Chat, id, :msgs}, [msg.id])
    if m.sender == msg.sender do
      SA.remove({Chat, id, :msgs}, msg.id)
      Swarm.publish(id, {:del, msg})
    end
  end
  def ttl(chat, msg, ttl) do
    Swarm.Task.register({:ttl, msg.id},
      __MODULE__, :del, [chat, msg],
      ttl + :os.system_time(:seconds))
  end

  defp new(id) do
    SA.replicate({Chat, id, :state})
    SA.replicate({Chat, id, :members})
    SA.replicate({Chat, id, :msgs})
  end
  defp join(chat, user) do
    User.join(user, chat)
    SA.write({Chat, chat.id, :members}, user, chat.role)
  end
end
