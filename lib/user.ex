defmodule User do
  import Macros
  use Swarm.Agent
  defstruct [:name, :pass, groups: %{}]
  def on_init(id), do: %User{name: id}

  def register(user, pass) do
    ok? new(user), do: pass(user, nil, pass)
  end
  def login(user, pass) do
    if pass(user) == pass, do: :ok,
    else: {:error, :user_pass_missmatch}
  end
  # fetch
  defp pass(id), do: fetch(id, :pass)
  def groups(id), do: fetch(id, :groups)
  # handle_fetch
  def handle_fetch(state, :pass), do: state.pass
  def handle_fetch(state, :groups), do: state.groups
  # emit
  def pass(id, old_pass, pass), do: emit(id, :pass, {old_pass, pass})
  def join(id, group), do: emit(id, :join, group)
  def leave(id, group_id), do: emit(id, :leave, group_id)
  def seen(id, group_id, time), do: emit(id, :seen, {group_id, time})
  # handle_event
  def handle_event(state, :pass, {old_pass, pass}) do
    if old_pass == state.pass
    do put_in(state.pass, pass)
    else state end
  end
  def handle_event(state, :join, group) do
    last_seen = get_in(state, [:groups, group.id, :last_seen])
    put_in(state.groups[group.id],
      if last_seen
      do put_in(group.last_seen, last_seen)
      else group end)
  end
  def handle_event(state, :leave, id) do
    update_in(state, [:groups], &Map.drop(&1, [id]))
  end
  def handle_event(state, :seen, {id, time}) do
    put_in(state.groups[id].last_seen, time)
  end
end
