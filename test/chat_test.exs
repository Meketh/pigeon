defmodule Chat.Test do
  use Test.Case, subject: Chat

  test "send message" do
    User.register(Pepe, :sarasa)

    wait()
    Group.new(UnGrupo,Pepe)

    eventually assert {id_group,_} = User.get_group(Pepe,UnGrupo)

    eventually assert [] = Chat.msgs(id_group)

    Chat.msg(id_group,Pepe,"un mensaje")

    eventually assert [%{id: _,sender: Pepe, text: "un mensaje",created: _,updated: _}] = Chat.msgs(id_group)
  end

  test "modify message" do
    User.register(Pepe, :sarasa)

    wait()

    Group.new(UnGrupo,Pepe)

    eventually assert {id_group,_} = User.get_group(Pepe,UnGrupo)
    eventually assert [] = Chat.msgs(id_group)

    eventually assert [%{id: id_mensaje,sender: Pepe, text: "un mensaje",created: _,updated: _}] = Chat.msg(id_group,Pepe,"un mensaje")

    wait()

    Chat.mod(id_group,Pepe,id_mensaje,"mensaje modificado")

    eventually assert [%{id: _,sender: Pepe, text: "mensaje modificado",created: _,updated: _}] = Chat.msgs(id_group)
  end

end
