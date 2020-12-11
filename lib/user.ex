import Macros
defmodule Group do
  defstruct [:name,
    role: :admin, # :member
    unreads: 0,
    last: :os.system_time]
end

defmodule User do
  use Swarm.Agent
  defstruct [:name, :pass, groups: %{}]
  def on_init(name), do: %User{name: name}

  def register(user, pass) do
    ok? User.new(user),
    do: User.pass(user, pass)
  end
  def login(user, pass) do
    if User.pass(user) == pass, do: :ok,
    else: {:error, :user_pass_missmatch}
  end

  def pass(name), do: fetch(name, :pass)
  def handle_fetch(state, :pass), do: state.pass
  def pass(name, pass), do: emit(name, :pass, pass)
  def handle_event(state, :pass, pass), do: put_in(state.pass, pass)

  def handle_info(info, {time, state}) do
    IO.inspect({info, {time, state}})
    {:noreply, {time, state}}
  end
end
