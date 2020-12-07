defmodule Ping.Application do
  use Application
  alias Horde.Registry as HReg
  alias Horde.DynamicSupervisor as HSup
  def start(_type, _args) do
    Supervisor.start_link([
      {HSup, [name: Horde, strategy: :one_for_one]},
      {HReg, [name: User.Registry, keys: :unique]},
      Monitor,
    ], [strategy: :one_for_one, name: Ping.Supervisor])
  end
end
