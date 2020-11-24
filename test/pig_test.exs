defmodule Pig.Test do
  use ExUnit.Case
  doctest Pig

  test "Usuario Sarasa no existe por eso rompe" do
    Pig.login("hernan")
    Pig.login("marian")
    Pig.send("hernan","marian", "hola 1")
    Pig.send("hernan","marian", "hola 2")
    Pig.send("hernan","marian", "hola 3")

    assert  true
  end
end
