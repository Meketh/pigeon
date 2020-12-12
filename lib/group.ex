defmodule Group do
  defstruct [:name,
    role: :admin,
    id: Nanoid.generate(),
    last_seen: :os.system_time,
    updated: :os.system_time]

  def merge(a, b) do
    if a.updated > b.updated, do: a, else: b
  end

  def pm_id(a, b), do: Enum.sort([a, b])
  def pm(a, b) do
    group = %Group{
      id: pm_id(a, b),
      role: :member,
      updated: :os.system_time}
    new_chat(group.id)
    join(group, a)
    join(group, b)
  end
  def new(name, admin) do
    group = %Group{name: name,
      id: Nanoid.generate(),
      updated: :os.system_time}
    new_chat(group.id)
    join(group, admin)
  end

  def add(%{role: role}, _) when role != :admin, do: {:error, :not_admin}
  def add(%Group{id: id, name: name}, user, role \\ :member) do
    %Group{id: id,
      name: name, role: role,
      updated: :os.system_time}
    |> join(user)
  end

  def remove(%{role: role}, _) when role != :admin, do: {:error, :not_admin}
  def remove(%Group{id: id}, user) do
    User.leave(user, id)
    Chat.leave(id, user)
  end

  # private
  defp join(%{id: id, role: role} = group, user) do
    User.join(user, group)
    Chat.join(id, user, role)
  end

  defp new_chat(id) do
    case Chat.new(id) do
      :ok -> :ok
      {:error, :already_registered} -> :ok
      _ -> new_chat(id)
    end
  end
end
