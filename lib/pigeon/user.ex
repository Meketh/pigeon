defmodule User do
  import Util
  use Swarm.Agent

  def register(id, pass) do
    ok? replicate(id, [:state, :groups]),
    do: pass(id, nil, pass)
  end
  def login(id, pass) do
    if pass(id) == pass, do: :ok,
    else: {:error, :user_pass_missmatch}
  end

  def pass(id), do: get(id, [:state, :pass])
  def pass(id, old_pass, new_pass) do
    update(id, [:state, :pass],
      mfa(:update_pass, [old_pass, new_pass]))
  end
  def update_pass(pass, old_pass, new_pass) do
    if pass == old_pass, do: new_pass, else: pass
  end

  def groups(id), do: get(id, [:groups])
  def join(id, group) do
    update(id, [:groups, group.id],
      mfa(:update_role, [group]))
  end
  def update_role(group, %{role: role}) do
    put_in(group.role, role)
  end
  def leave(id, group_id), do: set(id, [:groups, group_id], nil)
  # def seen(id, group_id, time) do
  #   set(id, [:groups, group_id, :seen], time)
  # end
end
