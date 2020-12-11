defmodule Group.Test do
  use ExUnit.Case
  doctest Group

  setup_all do
  end

  test "new group" do
    assert Group.new(Pepe, :sarasa) == :ok
    assert User.register(Pepe, :pituto) == {:error, :already_registered}
  end


end
