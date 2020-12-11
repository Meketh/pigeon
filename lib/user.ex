defmodule User do
  import Macros
  use Swarm.Agent
  defstruct [:name, :pass, groups: %{}]
  def on_init(id), do: %User{name: id}

  def register(user, pass) do
    ok? User.new(user),
    do: User.pass(user, pass)
  end
  def login(user, pass) do
    if User.pass(user) == pass, do: :ok,
    else: {:error, :user_pass_missmatch}
  end
  def add(a, b), do: Group.new({a, b})

  def pass(id), do: fetch(id, :pass)
  def groups(id), do: fetch(id, :groups)

  def handle_fetch(state, :pass), do: state.pass
  def handle_fetch(state, :groups), do: state.groups

  def pass(id, pass), do: emit(id, :pass, pass)

  def handle_event(state, :pass, pass), do: put_in(state.pass, pass)
  def handle_event(state, :join, group) do
    put_in(state.groups[group.id], group)
  end
end
