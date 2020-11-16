defmodule User.Test do
  use ExUnit.Case
  doctest User

  test "no encuentra usuarios inexistentes" do
    assert {:error, :not_found} = User.find("Sarasa")
  end

  test "encuentra usuarios nuevos" do
    User.start("Sarasa")
    assert {:ok, pid} = User.find("Sarasa")
    assert is_pid(pid)
  end

  test "sadhjfashdfkjasd" do
    # sender = "Pepito"
    # recipient = "Sarasa"
    # msg = "asjkhdfkashdfkasdf"
    # other_msg = "lkasjerkewj"

    # User.send(sender, recipient, msg)
    # assert is_pid(pid)
  end
end
