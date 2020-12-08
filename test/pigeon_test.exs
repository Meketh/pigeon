defmodule Pigeon.Test do
  use ExUnit.Case
  doctest Pigeon.Application

  test "Only one user with given name" do
    assert User.new(Pepe) == User.new(Pepe)
    assert Pepe == User.name(Pepe)
  end

  test "Creates agenda" do
    {:ok, _pid} = User.new(Pepe)
    assert %{} = Agenda.get(Pepe)
  end

  test "Stores contact" do
    {:ok, _pid} = User.new(Pepe)
    Agenda.add(Pepe, Juan)
    assert %{Juan => 0} = Agenda.get(Pepe)
  end
end
