defmodule Chat.Test do
  use Test.Case, subject: Chat

  test "send message" do
    User.register(Papo, :sarasa)
    User.register(Pepe, :sarasa)

    wait()
    Group.new(UnGrupo,Papo)

    wait()

    User.join(Pepe,UnGrupo)

    eventually assert [] = Chat.msgs(UnGrupo)

    Chat.msg(UnGrupo,Pepe,"un mensaje")

    eventually assert [%{id: _,sender: Pepe, text: "un mensaje",created: _,updated: _}] = Chat.msgs(UnGrupo)
  end

  test "modify message" do
    User.register(Papo, :sarasa)
    User.register(Pepe, :sarasa)

    wait()

    Group.new(UnGrupo,Papo)

    wait()

    User.join(Pepe,UnGrupo)

    eventually assert [] = Chat.msgs(UnGrupo)

    eventually assert [%{id: id_mensaje,sender: Pepe, text: "un mensaje",created: _,updated: _}] = Chat.msg(UnGrupo,Pepe,"un mensaje")

    wait()

    Chat.mod(UnGrupo,Pepe,id_mensaje,"mensaje modificado")

    eventually assert [%{id: _,sender: Pepe, text: "mensaje modificado",created: _,updated: _}] = Chat.msgs(UnGrupo)
  end

end
