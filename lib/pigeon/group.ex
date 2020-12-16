# defmodule Group do
#   defstruct [id: Nanoid.generate(), role: :admin, last_seen: 0]

#   def pm_id(a, b), do: Enum.sort([a, b])
#   def pm(a, b) do
#     cond do
#       not User.exsists(a) -> {:error, {:user_not_found, a}}
#       not User.exsists(b) -> {:error, {:user_not_found, b}}
#       true ->
#         id = pm_id(a, b)
#         if Chat.new(id, inspect id) == :ok do
#           group = %Group{id: id, role: :member, updated: :os.system_time}
#           join(group, a)
#           join(group, b)
#         end
#         id
#     end
#   end

#   def new(name, admin) do
#     id = Nanoid.generate()
#     Chat.new(id, name)
#     join(%Group{id: id}, admin)
#   end

#   def add(%{role: role}, _) when role != :admin, do: {error: :not_admin}
#   def add(%Group{id: id}, user, role \\ :member) do
#     join(%Group{id: id, role: role}, user)
#   end

#   def remove(%{role: role}, _) when role != :admin, do: {error: :not_admin}
#   def remove(%Group{id: id}, user) do
#     User.leave(user, id)
#     Chat.leave(id, user)
#   end

#   defp join(group, user) do
#     User.join(user, group)
#     Chat.join(group.id, user, group.role)
#   end
# end
