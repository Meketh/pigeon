# defmodule Chat.Test do
#   use ExUnit.Case
#   import Test.Helper
#   doctest Chat

#   setup_all do
#     User.register(Papo, :pass)
#   end

#   test "send message" do
#     User.register(Pepe, :sarasa)
#     Group.new(UnGrupo,Papo)

#     wait()

#     User.join(Pepe,UnGrupo)
#     wait()

#     assert [] = Chat.msgs(UnGrupo)

#     Chat.msg(UnGrupo,Pepe,"un mensaje")

#     wait()

#     assert [%{id: _,sender: Pepe, text: "un mensaje",created: _,updated: _}] = Chat.msgs(UnGrupo)
#   end

#   test "modify message" do
#     User.register(Pepe, :sarasa)
#     Group.new(UnGrupo,Papo)

#     wait()

#     User.join(Pepe,UnGrupo)
#     wait()

#     assert [] = Chat.msgs(UnGrupo)

#     assert [%{id: id_mensaje,sender: Pepe, text: "un mensaje",created: _,updated: _}] = Chat.msg(UnGrupo,Pepe,"un mensaje")

#     wait()

#     Chat.mod((UnGrupo,Pepe,id_mensaje,"mensaje modificado")
#     wait()

#     assert [%{id: _,sender: Pepe, text: "mensaje modificado",created: _,updated: _}] = Chat.msgs(UnGrupo)
#   end

# end
