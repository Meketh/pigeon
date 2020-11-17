defmodule Chat do
  use Agent
  def get_name(key), do: {:via, Registry, {Chat.Registry, key}}

  def start(key, integs \\ [], admin \\ nil) do
    admin_integs = if admin, do: [admin], else: []

    Agent.start_link(
      fn ->
        %{
          messages: [],
          integrants: Enum.concat(integs, admin_integs),
          admin_integrants: admin_integs
        }
      end,
      name: get_name(key)
    )
  end

  @spec find(any) :: {:error, :not_found} | {:ok, pid}
  def find(key) do
    # case Registry.lookup(User.Registry, key) do
    case Registry.lookup(Chat.Registry, key) do
      [{pid, _}] -> {:ok, pid}
      [] -> {:error, :not_found}
    end
  end

  def get_msgs(chat) do
    pid = get_name(chat)
    msgs = Agent.get(pid, &Map.get(&1, :messages))
    {:ok, msgs}
  end

  def get_all_integrants(chat) do
    pid = get_name(chat)
    intgs = Agent.get(pid, &Map.get(&1, :integrants))
    {:ok, intgs}
  end

  def get_admin_integrants(chat) do
    pid = get_name(chat)
    intgs = Agent.get(pid, &Map.get(&1, :admin_integrants))
    {:ok, intgs}
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

  def delete_intg(intgs, removed) do
    List.delete(intgs, removed)
  end

  def send(chat, sender, msg) do
    pid = get_name(chat)
    {:ok, msgs} = get_msgs(chat)
    new_messages = add_msg(msgs, sender, msg)
    Agent.update(pid, &Map.put(&1, :messages, new_messages))
  end

  def delete(chat, sender, date) do
    pid = get_name(chat)
    {:ok, msgs} = get_msgs(chat)
    new_messages = delete_msg(msgs, sender, date)
    Agent.update(pid, &Map.put(&1, :messages, new_messages))
  end

  def delete_integrant(chat, removed_integrant, admin) do
    pid = get_name(chat)
    {:ok, intgs} = get_all_integrants(chat)
    {:ok, admin_integs} = get_admin_integrants(chat)

    new_integrants = delete_intg(intgs, removed_integrant)
    new_admin_integrants = delete_intg(admin_integs, removed_integrant)

    Agent.update(pid, &Map.put(&1, :integrants, new_integrants))
    Agent.update(pid, &Map.put(&1, :admin_integrants, new_admin_integrants))
  end

  def add_integrant(chat, new_integrant, admin) do
    pid = get_name(chat)
    {:ok, intgs} = get_all_integrants(chat)

    new_integrants = add_intg(intgs, new_integrant)

    Agent.update(pid, &Map.put(&1, :integrants, new_integrants))
  end

  def make_admin(chat, new_admin, admin) do
    pid = get_name(chat)
    {:ok, admin_intgs} = get_admin_integrants(chat)

    if !Enum.member?(admin_intgs, admin) do
      {:error, :insuficient_permissions}
    else
      new_integrants = add_intg(admin_intgs, new_admin)

      Agent.update(pid, &Map.put(&1, :admin_integrants, new_integrants))
    end
  end

  def update(chat, sender, date, new_msg) do
    pid = get_name(chat)
    {:ok, msgs} = get_msgs(chat)
    new_messages = update_msg(msgs, sender, date, new_msg)
    Agent.update(pid, &Map.put(&1, :messages, new_messages))
  end

  def add_msg(msgs, sender, msg, date \\ DateTime.utc_now()) do
    modified = false
    List.insert_at(msgs, -1, {date, sender, msg, modified})
  end

  def add_intg(intgs, new_integrant) do
    List.insert_at(intgs, -1, new_integrant)
  end

  def new_chat(participants, name \\ nil) do
    if Enum.count(participants) < 2 do
      {:error, :insuficient_participants}
    else
      Chat.start(name || join_names(participants), participants)
    end
  end

  def new_group_chat(participants, admin, name \\ nil) do
    if Enum.count(participants) < 1 do
      {:error, :insuficient_participants}
    else
      Chat.start(name || join_names(Enum.concat(participants, [admin])), participants, admin)
    end
  end

  def join_names(participants) do
    Enum.sort(participants)
    |> Enum.join(":")
  end
end
