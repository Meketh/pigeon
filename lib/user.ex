defmodule User do
  import Util
  import Swarm.Agent

  # def group(id), do: {__MODULE__, id}
  def register(id, pass) do
    ok? replicate(id, [:state, :groups]),
    do: pass(id, nil, pass)
  end
  def login(id, pass) do
    if pass(id) == pass, do: :ok,
    else: {:error, :user_pass_missmatch}
  end

  def pass(id), do: get(id, [:state, :pass])
  def pass(id, old_pass, pass) do
    update(id, [:state, :pass], {__MODULE__, :update_pass, [old_pass, pass]})
  end
  def update_pass(pass, old_pass, new_pass) do
    if pass == old_pass, do: new_pass, else: pass
  end

  # # fetch
  # def groups(id), do: fetch(id, :groups)

  # # handle_fetch
  # def handle_fetch(state, :pass), do: state.pass
  # def handle_fetch(state, :groups), do: state.groups

  # # emit
  # def join(id, group), do: emit(id, :join, group)
  # def leave(id, group_id), do: emit(id, :leave, group_id)
  # def seen(id, group_id, time), do: emit(id, :seen, {group_id, time})

  # # handle_event
  # def handle_event(state, :pass, {old_pass, pass}) do
  #   if old_pass == state.pass
  #   do put_in(state.pass, pass)
  #   else state end
  # end
  # def handle_event(state, :join, group) do
  #   self_group = state.groups[group.id]
  #   self_group = put_in(group.last_seen,
  #     if self_group
  #     do self_group.last_seen
  #     else group.last_seen end)
  #   put_in(state.groups[group.id], self_group)
  # end
  # def handle_event(state, :leave, id) do
  #   state
  #   |> put_in([:groups, id, :role], :leave)
  #   |> put_in([:groups, id, :updated], :os.system_time)
  # end
  # def handle_event(state, :seen, {id, time}) do
  #   state
  #   |> put_in([:groups, id, :last_seen], time)
  #   |> put_in([:groups, id, :updated], :os.system_time)
  # end
end
