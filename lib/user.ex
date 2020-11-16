defmodule User do
  use Agent
  def get_name(key), do: {:via, Registry, {User.Registry, key}}
  def start(key) do
    Agent.start_link(fn -> [] end, name: get_name(key))
  end
  def find(key) do
    case Registry.lookup(User.Registry, key) do
      [{pid, _}] -> {:ok, pid}
      [] -> {:error, :not_found}
    end
  end

  # def send(sender, recipient, msg) when is_not_chat(recipient) do
  #   send(sender, topic, msg)
  # end
  def send(sender, chat, msg) do
    case find(sender) do
      {:error, :not_found} -> {:error, :sender_not_found}
      {:ok, pid} -> Chat.send(chat, sender, msg)
    end
  end
end
