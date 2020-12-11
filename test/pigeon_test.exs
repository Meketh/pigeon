defmodule Pigeon.Test do
  use ExUnit.Case
  doctest Pigeon.Application

  # setup do
  #   Pigeon.register(Pepe, Sarasa)
  # end

  test "Cant register twice" do
    assert :ok = Pigeon.register(Pepe, Sarasa)
    # assert {:error, :already_exists} == Pigeon.register(Pepe, Surukundum)
  end

  test "aksldhfsdfasdfkhj" do
  end

  # test "Only one user with given name" do
  #   assert User.new(Pepe) == User.new(Pepe)
  #   assert Pepe == User.name(Pepe)
  # end

  # test "Creates agenda" do
  #   {:ok, _pid} = User.new(Pepe)
  #   assert %{} = Agenda.get(Pepe)
  # end

  # test "Stores contact" do
  #   {:ok, _pid} = User.new(Pepe)
  #   Agenda.add(Pepe, Juan)
  #   assert %{Juan => 0} = Agenda.get(Pepe)
  # end
end
