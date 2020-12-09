defmodule Ping.Test do
  use ExUnit.Case
  doctest Ping.Application
  alias Horde.Registry, as: HR
  alias Horde.DynamicSupervisor, as: HDS
  alias Pigeon.Process, as: PP

  test "Crear user en otro nodo y preguntar su nombre" do
    nodo = get_random_node()
    key = "Pepe"

    {:ok, pepe} = User.new(key,"#{nodo}")

    assert ^key = User.name(pepe)
  end

  test "Crear user en otro nodo y encontrarlo en registry" do
    nodo = get_random_node()

    key = "Pepe"

    {:ok, _} = User.new(key,"#{nodo}")

    return_if_exists(key)

    [{un_pid, nil}] = HR.lookup(User.Registry, key)

    assert ^key = User.name(un_pid)
  end

  test "Crear multiples usuarios y poder acceder sus nombres desde el registry" do
    key_pepe = "Pepe"
    key_jose = "Jose"
    key_maria = "Maria"
    key_listorti = "Listorti"

    {:ok, _} = User.new(key_pepe,"#{get_random_node()}")
    {:ok, _} = User.new(key_jose,"#{get_random_node()}")
    {:ok, _} = User.new(key_maria,"#{get_random_node()}")
    {:ok, _} = User.new(key_listorti,"#{get_random_node()}")

    return_if_exists(key_pepe)
    return_if_exists(key_jose)
    return_if_exists(key_maria)
    return_if_exists(key_listorti)

    [{user_pepe, nil}] = HR.lookup(User.Registry, key_pepe)
    [{user_jose, nil}] = HR.lookup(User.Registry, key_jose)
    [{user_maria, nil}] = HR.lookup(User.Registry, key_maria)
    [{user_listorti, nil}] = HR.lookup(User.Registry, key_listorti)

    assert ^key_pepe = User.name(user_pepe)
    assert ^key_jose = User.name(user_jose)
    assert ^key_maria =User.name( user_maria)
    assert ^key_listorti =User.name( user_listorti)
  end

  test "Crear user en varios nodos sin repetir" do
    key = "Pepe"

    instances_before = length(PP.childrens_registered(key,User.Registry))

    resultado = User.dnew(key)

    Process.sleep(5000)

    instances_after = length(PP.childrens_registered(key,User.Registry))

    difference = instances_after - instances_before

    assert instances_before<=Pigeon.Process.get_max_instances()
    assert difference>=0
  end

  def get_user_instances(name) do

    children_pids = PP.childrens_registered(name,User.Registry)

    :logger.debug("CHILDREN PIDS: #{inspect children_pids}")

    children_pids
  end


  def get_random_node do
    nodes_to_choose = Enum.concat(Node.list(),[Node.self()])#["pigeon@10.0.0.2","pigeon@10.0.0.3","pigeon@10.0.0.4"]# Enum.filter(["pigeon@10.0.0.2","pigeon@10.0.0.3","pigeon@10.0.0.4"],fn n-> !(n=="Node.self) end)
    Enum.random(nodes_to_choose)
  end

  def return_if_exists(name) do
    Process.sleep(1000)
    if(length(get_user_instances(name))==0) do
      return_if_exists(name)
    end
  end

end
