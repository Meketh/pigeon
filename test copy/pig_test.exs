defmodule Pig.Test do
  use ExUnit.Case
  doctest Pig

  test "Envio de mensajes entre usuarios logueados" do
    assert {:ok,pidhernan} = Pig.login("hernan")
    assert {:ok,pidmarian} = Pig.login("marian")
    assert "hernan: hola marian" = Pig.send("hernan","marian", "hola marian")
    assert "marian: que tal hernan?" = Pig.send("marian","hernan", "que tal hernan?")
    assert 2 = Chat.get_msgs("hernan:marian")|> elem(1) |> length
  end

  # test "Envio de mensajes "
end
