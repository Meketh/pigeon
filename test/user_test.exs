defmodule User.Test do
  use ExUnit.Case
  doctest User
  import User

  setup_all do
    register(Papo, :pass)
  end

  test "register" do
    assert register(Pepe, :sarasa) == :ok
    assert register(Pepe, :pituto) == {:error, :already_registered}
  end

  test "login" do
    assert login(Papo, :pass) == :ok
    assert login(Papo, :no) == {:error, :user_pass_missmatch}
  end

  test "change pass" do
    assert register(Sapo, :sarasa) == :ok
    assert login(Sapo, :sarasa) == :ok

    assert pass(Sapo, :sarasa, :pass) == :ok
    assert pass(Sapo, :sarasa, :error) == :ok
    Proccess.sleep(3000)
    assert login(Sapo, :pass) == :ok
    assert login(Sapo, :error) == {:error, :user_pass_missmatch}
  end

  test "updates last seen" do
    assert groups(Papo) == %{}
    assert Group.pm(Papo, Pepe) == :ok
    gs = groups(Papo)
    id = Group.pm_id(Papo, Pepe)
    assert map_size(gs) == 1
    assert %{^id => %{id: ^id, name: nil}}= gs
  end
end
