defmodule Group do
  defstruct [:name,
    id: Nanoid.generate(),
    role: :admin,
    unreads: 0,
    last: :os.system_time]

  def new({a, b}) do
    group = %Group{
      id: Enum.sort([a, b]),
      role: :member}
    new_chat(group.id)
    join(a, group)
    join(b, group)
  end
  def new(name, admin) do
    group = %Group{name: name}
    new_chat(group.id)
    join(admin, group)
  end

  defp join(user, %{id: id, role: role} = group) do
    User.emit(user, :join, group)
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
