import Macros
defmodule Group do
  defstruct [:name,
    id: Nanoid.generate(),
    role: :admin, # :member
    unreads: 0,
    last: :os.system_time]
end

defmodule User do
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

  def pass(id), do: fetch(id, :pass)

  def handle_fetch(state, :pass), do: state.pass

  def pass(id, pass), do: emit(id, :pass, pass)
  def new_group(id, name), do: emit(id, :new_group, name)

  def handle_event(state, :pass, pass), do: put_in(state.pass, pass)
  def handle_event(state, :new_group, name) do
    group = %Group{name: name}
    put_in(state.groups[group.id], group)
  end

  # def handle_info(info, {time, state}) do
  #   IO.inspect({info, {time, state}})
  #   {:noreply, {time, state}}
  # end
end
