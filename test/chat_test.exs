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
    assert  [{t1, ^sender, ^msg,_}] = msgs

    :ok = Chat.send(chat, sender, other_msg)
    {:ok, msgs} = Chat.get_msgs(chat)
    assert [{^t1, ^sender, ^msg,_}, {t2, ^sender, ^other_msg,_}] = msgs
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

  test "Sarasa comete un orror de ortografia y modifica el mensaje" do
    sender="Sarasa"
    msg="che cuando ahi que rendir el parsial?"
    new_msg="che cuando hay que rendir el parcial?"
    chat="Juan:Sarasa"

    {:ok, pid} = Chat.new_chat(["Sarasa", "Juan"])
    :ok = Chat.send(chat, sender, msg)
    {:ok, msgs} = Chat.get_msgs(chat)

    {date,sender, msg,_} = Enum.at(msgs,-1)

    assert :ok = Chat.update(chat,sender,date,new_msg)

    {:ok, msgs} = Chat.get_msgs(chat)

    assert {^date,^sender, ^new_msg,_} = Enum.at(msgs,-1)

  end

  test "Sarasa insulta a Juan, se acobarda y elimina el mensaje" do
    sender="Sarasa"
    msg="Eh Juan, sos un pelado cobolero"
    chat="Juan:Sarasa"

    {:ok, pid} = Chat.new_chat(["Sarasa", "Juan"])
    :ok = Chat.send(chat, sender, msg)
    {:ok, msgs} = Chat.get_msgs(chat)

    {date,sender, msg,_} = Enum.at(msgs,-1)

    assert :ok = Chat.delete(chat,sender,date)

    assert {:ok, []} = Chat.get_msgs(chat)
  end

  test "Sarasa crea un grupo con sus amigos y manda un mensaje" do
    group_integrants = ["Juan","Maria"]
    admin = "Sarasa"
    chat="TP IASC 2020"
    msg = "Mensaje de prueba"

    {:ok, pid} = Chat.new_group_chat(group_integrants,admin,chat)
    :ok = Chat.send(chat, admin, msg)
    {:ok, msgs} = Chat.get_msgs(chat)

    assert {:ok, [{date,^admin, ^msg,_}]} = Chat.get_msgs(chat)
  end

  test "Sarasa se enoja con Juan y lo saca del grupo" do
    group_integrants = ["Juan","Maria"]
    admin = "Sarasa"
    chat="TP IASC 2020"
    removed_integrant="Juan"

    {:ok, pid} = Chat.new_group_chat(group_integrants,admin,chat)
    :ok = Chat.delete_integrant(chat,removed_integrant,admin)

    assert {:ok,["Maria","Sarasa"]} = Chat.get_all_integrants(chat)
  end

  test "Sarasa crea grupo y agrega a Hercules" do
    group_integrants = ["Juan","Maria"]
    admin = "Sarasa"
    chat="TP IASC 2020"
    new_integrant="Hercules"

    {:ok, pid} = Chat.new_group_chat(group_integrants,admin,chat)
    :ok = Chat.add_integrant(chat,new_integrant,admin)

    new_integrants=Enum.concat(group_integrants,[admin,new_integrant])

    assert {:ok,^new_integrants} = Chat.get_all_integrants(chat)
  end

  test "Zeus hace admin a Hercules por ser su hijo" do
    group_integrants = ["Hestia","Hercules"]
    admin = "Zeus"
    chat="Olimpo"
    new_admin="Hercules"

    {:ok, pid} = Chat.new_group_chat(group_integrants,admin,chat)

    assert {:ok,["Zeus"]} = Chat.get_admin_integrants(chat)

    :ok = Chat.make_admin(chat,new_admin,admin)

    assert {:ok,["Zeus","Hercules"]} = Chat.get_admin_integrants(chat)
  end

  test "Sarasa quiere hacer admin a Hercules y no puede por no ser un semidios" do
    group_integrants = ["Sarasa","Hercules"]
    admin = "Zeus"
    chat="Olimpo"
    new_admin="Hercules"

    {:ok, pid} = Chat.new_group_chat(group_integrants,admin,chat)

    assert {:ok,["Zeus"]} = Chat.get_admin_integrants(chat)

    assert {:error, :insuficient_permissions} = Chat.make_admin(chat,new_admin,"Sarasa")

    assert {:ok,["Zeus"]} = Chat.get_admin_integrants(chat)
  end
end
