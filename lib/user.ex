defmodule Group do
  defstruct [:name,
    role: :admin, # :member
    unreads: 0,
    last: :os.system_time]
end

defmodule User do
  use Cluster.Agent
  defstruct [:name, :pass, groups: %{}]
  def on_init(id), do: %User{name: id}

  def set_pass(id, pass), do: emit(id, {:set_pass, pass})
  def handle_info({:set_pass, pass}, state) do
    IO.puts(["SARASA", pass, state, put_in(state.pass, pass)])
    {:noreply, put_in(state.pass, pass)}
  end

  def handle_info(info, state) do
    IO.puts({info, state})
    {:noreply, state}
  end
end

# handle_info({group, event}, state)
# {:ok, %User{name: name}, {:continue, {:init, name}}}
# handle_continue({:init, name}, state)
