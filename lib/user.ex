defmodule Group do
  defstruct [:name,
    role: :admin, # :member
    unreads: 0,
    last: :os.system_time]
end

defmodule User do
  use Cluster.Agent
  defstruct [:id, :pass, groups: %{}]
  def set_pass(user, pass), do: emit(user, :set_pass, [pass])
  def handle_info({{User, id}, {:set_pass, pass}}, state)
  when state.id == id do
    {:noreply, put_in(state.pass, pass)}
  end
end

# handle_info({group, event}, state)
# {:ok, %User{name: name}, {:continue, {:init, name}}}
# handle_continue({:init, name}, state)
