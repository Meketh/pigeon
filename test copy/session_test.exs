defmodule Session.Test do
  use ExUnit.Case
  doctest Session
  doctest Pig

  test "Usuario Sarasa no existe por eso rompe" do
    assert {:error, :user_not_found} = Session.find("Sarasa")
  end

  test "Creo a Sarasa y pero no tiene ninguna sesion creada" do
    Session.start("Sarasa")
    assert {:error, :session_not_found} = Session.find("Sarasa")
  end

  test "me logueo con sarasa y luego lo busco" do
    Pig.login("Sarasa")
    assert {:ok, pid} = Session.find("Sarasa")
    assert is_pid(pid)
  end
end
