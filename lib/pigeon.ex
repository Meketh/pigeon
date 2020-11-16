defmodule Pigeon do
  use Application

  def start(_type, _args) do
    Supervisor.start_link([
      {Registry, [keys: :unique, name: User.Registry]},
      {Registry, [keys: :unique, name: Chat.Registry]},
      {Registry, [keys: :unique, name: Recipient.Registry]},
      # User.Supervisor,
      # Chat.Supervisor,
      # %{id: Chat.Index, start: {Agent, :start_link, [fn -> %{} end]}},
      # %{id: Chat.Registry, start: {Registry, :start_link, [keys: :unique]} },
      # %{id: Chat.Supervisor, start: {DynamicSupervisor, :start_link, [[]]} },
    ], [strategy: :one_for_one, name: __MODULE__])
  end

  def signup(nick), do: User.start(nick)
  def signin(nick), do: User.find(nick)
end
