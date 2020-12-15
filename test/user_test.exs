defmodule User.Test do
  use Test.Case, subject: User

  # test "register" do
  #   assert register(Reg, :sarasa) == :ok
  #   assert register(Reg, :pituto) == {:error, :already_registered}
  # end

  # test "login" do
  #   register(Log, :pass)
  #   assert login(Log, :pass) == :ok
  #   assert login(Log, :no) == {:error, :user_pass_missmatch}
  # end

  # test "change pass" do
  #   assert register(Pass, :sarasa) == :ok
  #   assert login(Pass, :sarasa) == :ok
  #   assert pass(Pass, :sarasa, :pass) == :ok
  #   assert pass(Pass, :jojojo, :error) == :ok
  #   assert login(Pass, :error) == {:error, :user_pass_missmatch}
  #   assert login(Pass, :pass) == :ok
  # end

  # test "updates last seen" do
  #   register(Seer, :pass)
  #   register(Seen, :pass)
  #   assert login(Seer, :pass) == :ok
  #   assert login(Seen, :pass) == :ok
  #   assert groups(Seer) == %{}
  #   assert groups(Seen) == %{}

  #   id = Group.pm_id(Seer, Seen)
  #   assert Group.pm(Seer, Seen) == :ok
  #   assert map_size(groups(Seer)) == 1
  #   assert map_size(groups(Seen)) == 1
  #   assert %{^id => %{id: ^id, name: nil}} = groups(Seer)
  #   assert %{^id => %{id: ^id, name: nil}} = groups(Seen)
  #   # Seer.seen -> saw
  # end
end
