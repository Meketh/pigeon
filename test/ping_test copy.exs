# defmodule Ping.Test do
#   use ExUnit.Case
#   doctest Ping.Application
#   alias Horde.Registry, as: HR

#   test "Only one user with given name" do
#     {:ok, pepe} = User.new("Pepe")
#     assert {:ok, ^pepe} = User.new("Pepe")
#     assert [{^pepe, nil}] = HR.lookup(User.Registry, "Pepe")
#   end

#   test "User creates agenda" do
#     {:ok, _pepe} = User.new("Pepe")
#     agenda = Agenda.via("Pepe")
#     assert %{} = Agenda.get(agenda)
#   end

#   test "User adds chat to agenda" do
#     {:ok, _pepe} = User.new("Pepe")
#     agenda = Agenda.via("Pepe")
#     Agenda.add(agenda,"un_chat")
#     assert %{"un_chat"=>0} = Agenda.get(agenda)
#   end

#   test "Multiple users adds chat to agenda" do
#     {:ok, _} = User.new("Pepe")
#     {:ok, _} = User.new("Jose")
#     {:ok, _} = User.new("Maria")
#     {:ok, _} = User.new("Listorti")

#     Process.sleep(8000)

#     agenda_pepe = Agenda.via("Pepe")
#     agenda_jose = Agenda.via("Jose")
#     agenda_maria = Agenda.via("Maria")
#     agenda_listorti = Agenda.via("Listorti")

#     Agenda.add(agenda_jose,"chat_jose")
#     Agenda.add(agenda_listorti,"chat_listorti")

#     assert %{"chat_jose"=>0} = Agenda.get(agenda_jose)
#     assert %{"chat_listorti"=>0} = Agenda.get(agenda_listorti)
#     assert %{} = Agenda.get(agenda_pepe)
#     assert %{} = Agenda.get(agenda_maria)
#   end

#   test "Prueba de concepto replicacion agenda" do

#     {:ok,agenda_pepe} = Agenda.dnew("Pepe",["","2"])
#     agenda_copia = Agenda.via("Pepe_2")

#     Process.sleep(8001)

#     assert %{} = Agenda.get(agenda_pepe)
#     assert %{} = Agenda.get(agenda_copia)

#     Agenda.add(agenda_pepe,"chat_nuevo")

#     Process.sleep(100)

#     assert %{"chat_nuevo"=>0} = Agenda.get(agenda_pepe)
#     assert %{"chat_nuevo"=>0} = Agenda.get(agenda_copia)
#   end
# end
