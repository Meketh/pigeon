defmodule Pigeon.Application do
  use Application
  def start(_type, _args) do
    Supervisor.start_link([
      {Room.Dynamic.Supervisor, start: {Room.Dynamic.Supervisor, :start_link, [[]]} },
      {User.Supervisor,  []},
      {Registry, [keys: :unique, name: User.Registry]},
      {Registry, [keys: :unique, name: Session.Registry]},
      {Registry, [keys: :unique, name: Chat.Registry]},
      {Registry, [keys: :unique, name: Room.Registry]}
    ], [strategy: :one_for_one, name: __MODULE__])
  end
end
