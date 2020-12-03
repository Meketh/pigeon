defmodule Pigeon do
  use Application

  def start(_type, _args) do
    children = [
      {Chat.Supervisor,  []},
      {Room.Supervisor,  []},
      {User.Supervisor,  []},
      {Registry, [keys: :unique, name: User.Registry]},
      {Registry, [keys: :unique, name: Chat.Registry]},
      {Registry, [keys: :unique, name: Room.Registry]}
    ]
    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end
end
