defmodule Ping.Test do
  use ExUnit.Case
  doctest Ping.Application
  alias Horde.Registry, as: HR

  test "Only one user with given name" do
    {:ok, pepe} = User.new("Pepe")
    assert {:ok, ^pepe} = User.new("Pepe")
    assert [{^pepe, nil}] = HR.lookup(User.Registry, "Pepe")
  end

  test "User creates agenda" do
    {:ok, _pepe} = User.new("Pepe")
    agenda = Agenda.via("Pepe")
    assert %{} = Agenda.get(agenda)
  end
end
