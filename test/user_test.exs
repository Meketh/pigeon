defmodule User.Test do
  use ExUnit.Case
  doctest User

  setup_all do
    User.register(Papo, :pass)
  end

  test "register" do
    assert User.register(Pepe, :sarasa) == :ok
    assert User.register(Pepe, :pituto) == {:error, :already_registered}
  end

  test "login" do
    assert User.login(Papo, :pass) == :ok
    assert User.login(Papo, :no) == {:error, :user_pass_missmatch}
  end

  test "add" do
    assert User.login(Papo, :pass) == :ok
    assert Group.new_pm(Papo,Pepe) == :ok
    group_id = Group.pm_id(Papo, Pepe)
    assert Chat.msg(group_id, Papo, "hola")  == :ok
    assert Chat.msgs(group_id) |> Map.keys |> length == 1

    assert Chat.msg(group_id, Papo, "estas?")  == :ok
    # assert Chat.msgs(group_id) |> Map.keys |> length == 2

    # assert User.send(Papo,groupid,)
  end


end
