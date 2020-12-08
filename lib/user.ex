defmodule User do
  use GenServer
  use Swarm.Supervisor
  def start_link(name) do
    GenServer.start_link(__MODULE__, name)
    # case Agenda.new(name) do
    #   {:ok, _} -> GenServer.start_link(__MODULE__, name)
    #   error -> error
    # end
  end
  def init(name) do
    {:ok, name, {:continue, :agenda}}
  end
  def handle_continue(:agenda, name) do
    Agenda.new(name)
    {:noreply, name}
  end
  def name(name) do
    GenServer.call(via(name), {:name})
  end
  def handle_call({:name}, _from, name) do
    {:reply, name, name}
  end
end

# defmodule User do
#   # use GenServer, restart: :transient
#   def horde(), do: [
#     {Horde.Registry, [name: __MODULE__.Registry, keys: :unique]},
#     {Horde.DynamicSupervisor, [name: __MODULE__.Supervisor,
#       members: :auto,
#       strategy: :one_for_one,
#       distribution_strategy: Horde.Distribution,
#     ]}]
#   def id(name), do: name
#   # def id(name), do: {__MODULE__, name}
#   # def id(name), do: "#{__MODULE__}_#{name}"
#   def via(name), do: {:via, Horde.Registry, {__MODULE__.Registry, id(name)}}
#   def new(name), do: Horde.DynamicSupervisor.start_child(__MODULE__.Supervisor, %{
#     id: id(name), restart: :transient,
#     start: {__MODULE__, :start_link, [name]},
#   })
#   def start_link(name) do
#     case GenServer.start_link(__MODULE__, via(name)) do
#       {:ok, pid} -> {:ok, pid}
#       {:error, {:already_started, pid}} -> {:ok, pid}
#       error -> error
#     end
#   end
#   def init(name) do
#     :logger.debug("#{Node.self()}/#{__MODULE__}_#{name}")
#     # {:ok, _} = Agenda.new(name)
#     {:ok, name}
#   end
#   def name(pid) do
#     GenServer.call(pid, {:name})
#   end
#   def handle_call({:name}, _from, name) do
#     {:reply, name, name}
#   end

#   # Swarm.Callbacks / Handoff: :restart | :ignore | {:resume, handoff}
#   def handle_call({:swarm, :begin_handoff}, _from, state), do: {:reply, :restart, state}
#   def handle_cast({:swarm, :end_handoff, _handoff}, state), do: {:noreply, state}
#   def handle_cast({:swarm, :resolve_conflict, _conflict}, state), do: {:noreply, state}
#   def handle_info({:swarm, :die}, state), do: {:stop, :shutdown, state}
# end
