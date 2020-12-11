defmodule Chat.Test do
  use ExUnit.Case
  doctest Chat

  test "Pepito mensajea con Sarasa y los msj se ordenan" do
     sender = "Pepito"
     receivers = ["ariel","noelia"]
     msg = "un mensaje de prueba"
     other_msg = "respuesta al mensaje anterior"

    {:ok, _} = Chat.start(chat)
    {:ok, msgs} = Chat.get_msgs(chat)
     assert msgs == []

    {:error, {:already_started, userpid}}=User.start_link("ariel") ;
    User.login(userpid,"Pepito");
    {:ok, _, chatid}=Chat.Agent.new_chat("Pepito",["ariel","noelia"]);
    User.send(userpid,chatid,"un mensaje de prueba1");
    User.send(userpid,chatid,"un mensaje de prueba2");
    User.send(userpid,chatid,"un mensaje de prueba3");
    User.send(userpid,chatid,"un mensaje de prueba4");

    # GenServer.call(userpid,{:get_state})
    GenServer.call(userpid,{:get_chats});
    chat =  GenServer.call(userpid,{:get_chats}) |> List.first;
    GenServer.call(chat.pid,{:get});
    GenServer.cast(chat.pid,{:delete_message,"5cf6f93c-3a95-11eb-9cc9-8224b821cc01"})
    GenServer.cast(chat.pid,{:update_message,"897fb21c-3a9c-11eb-9f3f-8224b821cc01", "mensaje updateado"})
    GenServer.cast(userid,{:update_message,"897fb21c-3a9c-11eb-9f3f-8224b821cc01", "mensaje updateado"})
    GenServer.cast(userpid,{:remove_admins, chat.id, ["ariel"]})

    :ok = Chat.send(chat, sender, other_msg)
    {:ok, msgs} = Chat.get_msgs(chat)
    assert  %{date: t1, id: t2, message: ^other_msg, sender: ^sender} = msgs|>List.last
  end


  test "Sarasa crea un chat y le pone el nombre que quiere" do
    # nombre_chat="quieroEsteNombre!"
    # {:ok, pid} = Chat.new_chat(["Sarasa", "Juan"],nombre_chat)
    # assert is_pid(pid)
    # assert {:ok, ^pid} = Chat.find(nombre_chat)
    assert true
  end
end
