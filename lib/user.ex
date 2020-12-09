defmodule User do
  use Cluster.Agent
  defstruct [:name, chats: %MapSet{}]
  def init(name) do
    # Agenda.new(name)
    %User{name: name}
  end
  def name(name), do: get(name, :get_name)
  def get_name(state), do: state.name
end
