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
end
