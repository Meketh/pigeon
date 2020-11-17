defmodule Chat.Test do
  use ExUnit.Case
  doctest Chat

  test "Pepito mensajea con Sarasa y los msj se ordenan" do
    chat = "Sarasa"
    sender = "Pepito"
    msg = "un mensaje de prueba"
    other_msg = "respuesta al mensaje anterior"

    {:ok, _} = Chat.start(chat)
    {:ok, msgs} = Chat.get_msgs(chat)
    assert msgs == []

    :ok = Chat.send(chat, sender, msg)
    {:ok, msgs} = Chat.get_msgs(chat)
    assert  [{t1, ^sender, ^msg}] = msgs

    :ok = Chat.send(chat, sender, other_msg)
    {:ok, msgs} = Chat.get_msgs(chat)
    assert [{^t1, ^sender, ^msg}, {t2, ^sender, ^other_msg}] = msgs
  end

  test "Creo un chat vacio y rompe (porque esta vacio...)" do
    assert {:error, :insuficient_participants} = Chat.new_chat([])
  end

  test "Sarasa crea un chat y lo encuentra por nombre default" do
    {:ok, pid} = Chat.new_chat(["Sarasa", "Juan"])
    assert is_pid(pid)
    assert {:ok, ^pid} = Chat.find("Juan:Sarasa")
  end

  test "Sarasa crea un chat y le pone el nombre que quiere" do
    nombre_chat="quieroEsteNombre!"
    {:ok, pid} = Chat.new_chat(["Sarasa", "Juan"],nombre_chat)
    assert is_pid(pid)
    assert {:ok, ^pid} = Chat.find(nombre_chat)
  end
end
