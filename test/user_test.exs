defmodule User.Test do
  use Test.Case, subject: User

  test "register" do
    assert register(Reg, :sarasa) == :ok
    assert register(Reg, :pituto) == {:error, :already_registered}
  end

  test "login" do
    register(Log, :pass)
    assert login(Log, :pass) == :ok
    assert login(Log, :no) == {:error, :user_pass_missmatch}
  end

  test "change pass" do
    assert register(Pass, :sarasa) == :ok
    assert login(Pass, :sarasa) == :ok
    assert pass(Pass, :sarasa, :pass) == :ok
    assert pass(Pass, :jojojo, :error) == nil
    assert login(Pass, :error) == {:error, :user_pass_missmatch}
    assert login(Pass, :pass) == :ok
  end
end
