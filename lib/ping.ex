# user create agenda
# agenda replication

defmodule Ping.Application do
  use Application
  def start(_type, _args) do
    Supervisor.start_link([
      {Horde.Registry, [name: User.Registry, keys: :unique,members: :auto]},
      # {Horde.Registry, [name: Agenda.Registry, keys: :unique]},
      {Horde.DynamicSupervisor, [name: Horde,
        members: :auto,
        strategy: :one_for_one,
        distribution_strategy: State.Distribution,
      ]},
      # {Horde.DynamicSupervisor, [name: Agenda.Supervisor,
      #   members: :auto,
      #   strategy: :one_for_one,
      #   distribution_strategy: State.Distribution,
      # ]},
    ], [strategy: :one_for_one, name: Ping.Supervisor])
  end
end
