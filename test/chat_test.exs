defmodule Chat.Test do
  use Test.Case, subject: Chat

  setup do
    clean_swarm_context()
  end


  test "send message" do
    User.register(Pepe, :sarasa)

    eventually assert Group.new(UnGrupo, Pepe) == :ok

    wait()

    eventually assert {id_group, _} = User.get_group(Pepe, UnGrupo)

    eventually assert %{} = Chat.msgs(id_group)

    Chat.msg(id_group, Pepe, "un mensaje")

    eventually(
      assert [%Chat.Msg{id: some_id, sender: Pepe, text: "un mensaje", created: _, updated: _}] =
               Map.values(Chat.msgs(id_group))
    )
  end

  test "modify message" do
    User.register(Pepe, :sarasa)

    eventually assert Group.new(UnGrupo, Pepe) == :ok

    wait()

    eventually assert {id_group, _} = User.get_group(Pepe, UnGrupo)
    eventually assert %{} = Chat.msgs(id_group)

    Chat.msg(id_group, Pepe, "un mensaje")

    eventually(
      assert [%Chat.Msg{id: some_id, sender: Pepe, text: "un mensaje", created: _, updated: _}] =
               Map.values(Chat.msgs(id_group))
    )

    id_mensaje = Enum.at(Map.keys(Chat.msgs(id_group)), 0)

    Chat.mod(id_group, Pepe, id_mensaje, "mensaje modificado")

    eventually(
      assert [
               %Chat.Msg{
                 id: some_id,
                 sender: Pepe,
                 text: "mensaje modificado",
                 created: _,
                 updated: _
               }
             ] = Map.values(Chat.msgs(id_group))
    )
  end

  test "delete message" do
    User.register(Pepe, :sarasa)

    eventually assert Group.new(UnGrupo, Pepe) == :ok

    wait()

    eventually assert {id_group, _} = User.get_group(Pepe, UnGrupo)

    Chat.msg(id_group, Pepe, "un mensaje")

    eventually(
      assert [
               %Chat.Msg{
                 id: some_id,
                 sender: Pepe,
                 text: "un mensaje",
                 created: _,
                 updated: _
               }
             ] = Map.values(Chat.msgs(id_group))
    )

    id_mensaje = Enum.at(Map.keys(Chat.msgs(id_group)), 0)

    Chat.del(id_group, Pepe, id_mensaje)

    eventually assert %{} = Chat.msgs(id_group)
  end
end
