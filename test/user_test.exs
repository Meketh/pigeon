defmodule User.Test do
  use ExUnit.Case
  import Test.Helper
  doctest User

  setup_all do
    User.register(Papo, :pass)
  end

  test "register" do
    assert User.register(Pepe, :sarasa) == :ok
    wait()
    assert User.register(Pepe, :pituto) == {:error, :already_registered}
  end

  test "login" do
    assert User.login(Papo, :pass) == :ok
    wait()
    assert User.login(Papo, :no) == {:error, :user_pass_missmatch}
  end

  test "change pass" do
    assert User.register(Sapo, :sarasa) == :ok
    wait()
    assert User.login(Sapo, :sarasa) == :ok

    assert User.pass(Sapo, :sarasa, :pass) == :ok
    wait()
    assert User.login(Sapo, :pass) == :ok

    assert User.pass(Sapo, :sarasa, :error) == :ok
    wait()
    assert User.login(Sapo, :error) == {:error, :user_pass_missmatch}
  end
end
