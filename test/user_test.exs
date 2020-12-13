defmodule User.Test do
  use Test.Case, subject: User

  test "register" do
    assert register(Reg, :sarasa) == :ok
    eventually assert register(Reg, :pituto) == {:error, :already_registered}
  end

  test "login" do
    register(Log, :pass)
    eventually assert login(Log, :pass) == :ok
    eventually assert login(Log, :no) == {:error, :user_pass_missmatch}
  end

  test "change pass" do
    assert register(Pass, :sarasa) == :ok
    eventually assert login(Pass, :sarasa) == :ok
    assert pass(Pass, :sarasa, :pass) == :ok
    assert pass(Pass, :jojojo, :error) == :ok
    eventually assert login(Pass, :error) == {:error, :user_pass_missmatch}
    eventually assert login(Pass, :pass) == :ok
  end

  test "updates last seen" do
    register(Seen, :pass)
    assert groups(Seen) == %{}
    assert Group.pm(Seen, Pepe) == :ok
    id = Group.pm_id(Seen, Pepe)
    eventually assert map_size(groups(Seen)) == 1
    assert %{^id => %{id: ^id, name: nil}} = groups(Seen)
  end

  test "join to group" do
    User.register(Papo, :sarasa)
    User.register(Sapo, :sarasa)

    wait()

    Group.new(UnGrupo, Papo)

    eventually assert {id_group, _} = User.get_group(Papo, UnGrupo)

    User.join(Sapo, UnGrupo)

    eventually assert Enum.any?(Chat.members(id_group), fn m -> m == Sapo end)
  end

  test "leave group" do
    User.register(Papo, :sarasa)
    User.register(Sapo, :sarasa)

    wait()

    Group.new(UnGrupo, Papo)

    eventually assert {id_group, _} = User.get_group(Papo, UnGrupo)

    User.join(Sapo, UnGrupo)

    eventually assert Enum.any?(Chat.members(id_group), fn m -> m == Sapo end)

    User.leave(Sapo, id_group)

    eventually assert !Enum.any?(Chat.members(id_group), fn m -> m == Sapo end)
  end
end
