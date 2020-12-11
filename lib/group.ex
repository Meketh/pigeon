defmodule Group do
  defstruct [:name,
    id: Nanoid.generate(),
    last_seen: :os.system_time,
    role: :admin]

  def pm_id(a, b), do: Enum.sort([a, b])
  def new_pm(a, b) do
    group = %Group{
      id: pm_id(a, b),
      role: :member}
    new_chat(group.id)
    join(group, a)
    join(group, b)
  end
  def new(name, admin) do
    group = %Group{name: name}
    new_chat(group.id)
    join(group, admin)
  end

  def add(%{role: role}, _) when role != :admin, do: {:error, :not_admin}
  def add(%Group{id: id, name: name}, user, role \\ :member) do
    %Group{id: id, name: name, role: role}
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
