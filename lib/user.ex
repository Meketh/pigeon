defmodule User do
  alias Swarm.Agent, as: SA
  alias Swarm.Supervisor, as: SS

  def exists(id) do
    SS.replicated({User, id, :state})
    and SS.replicated({User, id, :chats})
  end
  def register(id, pass) do
    if exists(id) do
      {:error, :already_registered}
    else
      SA.replicate({User, id, :state})
      SA.replicate({User, id, :chats})
      pass(id, nil, pass)
    end
  end
  def login(id, pass) do
    if pass(id) == pass, do: :ok,
    else: {:error, :user_pass_missmatch}
  end

  def pass(id), do: SA.read({User, id, :state}, [:pass])
  def pass(id, old_pass, new_pass) do
    if pass(id) == old_pass do
      SA.write({User, id, :state}, :pass, new_pass)
    end
  end

  def chats(id), do: SA.read({User, id, :chats})
  def leave(id, chat), do: SA.remove({User, id, :chats}, chat.id)
  def join(id, chat) do
    SA.update({User, id, :chats}, [chat.id], fn c ->
      if c == nil, do: chat,
      else: put_in(c.role, chat.role)
    end)
  end
  def seen(id, chat, time) do
    SA.set({User, id, :chats}, [chat.id, :last_seen], time)
  end
end
