defmodule Chat do
  use Agent
  def get_name(key), do: {:via, Registry, {Chat.Registry, key}}

  def start(key) do
    Agent.start_link(fn -> [] end, name: get_name(key))
  end

  def find(key) do
    # case Registry.lookup(User.Registry, key) do
    case Registry.lookup(Chat.Registry, key) do
      [{pid, _}] -> {:ok, pid}
      [] -> {:error, :not_found}
    end
  end

  def get_msgs(chat) do
    msgs =
      get_name(chat)
      |> Agent.get(& &1)

    {:ok, msgs}
  end

  def update_msg(msgs, sender, date, new_msg) do
    Enum.map(msgs, fn existing_msg ->
      case existing_msg do
        {^date, ^sender, _, _} -> {date, sender, new_msg, true}
        _ -> existing_msg
      end
    end)
  end

  def find_msg(msgs, sender, date) do
    Enum.find(msgs, fn existing_msg ->
      case existing_msg do
        {^date, ^sender, _, _} -> true
        _ -> false
      end
    end)
  end

  def delete_msg(msgs, sender, date) do
    List.delete(msgs, find_msg(msgs, sender, date))
  end

  def send(chat, sender, msg) do
    get_name(chat)
    |> Agent.update(&add_msg(&1, sender, msg))
  end

  def delete(chat, sender, date) do
    get_name(chat)
    |> Agent.update(&delete_msg(&1, sender, date))
  end

  def update(chat, sender, date, new_msg) do
    get_name(chat)
    |> Agent.update(&update_msg(&1, sender, date, new_msg))
  end

  def add_msg(msgs, sender, msg, date \\ DateTime.utc_now()) do
    modified = false
    List.insert_at(msgs, -1, {date, sender, msg, modified})
  end

  def new_chat(participants, name \\ nil) do
    if Enum.count(participants) < 2 do
      {:error, :insuficient_participants}
    else
      Chat.start(name || join_names(participants))
    end
  end

  def join_names(participants) do
    Enum.sort(participants)
    |> Enum.join(":")
  end
end
