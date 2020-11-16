defmodule Chat.Test do
  use ExUnit.Case
  doctest Chat

  test "guarda los mensajes ordenados" do
    chat = "Sarasa"
    sender = "Pepito"
    msg = "asjkhdfkashdfkasdf"
    other_msg = "lkasjerkewj"

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

  test "asdjfjkasdhgfkasd" do
    assert {:error, :insuficient_participants} = Chat.new_chat([])
    {:ok, pid} = Chat.new_chat(["Sarasa", "Juan"])
    assert is_pid(pid)
    assert {:ok, ^pid} = Chat.find("Juan:Sarasa")
  end
end
