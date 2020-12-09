defmodule Ping.Test do
  use ExUnit.Case
  doctest Ping.Application
  alias Horde.Registry, as: HR
  alias Horde.DynamicSupervisor, as: HDS

  test "Crear user en otro nodo y preguntar su nombre" do
    nodo = get_random_node()

    key = "Pepe"
    # key = "Pepe_#{nodo}"

    {:ok, pepe} = User.new(key,"#{nodo}")

    assert ^key = User.name(pepe)
  end

  test "Crear user en otro nodo y encontrarlo en registry" do
    nodo = get_random_node()

    key = "Pepe"

    {:ok, pepe} = User.new(key,"#{nodo}")

    Process.sleep(5000)

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

    Process.sleep(5000)

    [{user_pepe, nil}] = HR.lookup(User.Registry, key_pepe)
    [{user_jose, nil}] = HR.lookup(User.Registry, key_jose)
    [{user_maria, nil}] = HR.lookup(User.Registry, key_maria)
    [{user_listorti, nil}] = HR.lookup(User.Registry, key_listorti)

    user_pepe_2 = User.via(key_pepe)
    user_jose_2 = User.via(key_jose)
    user_maria_2 = User.via(key_maria)
    user_listorti_2 = User.via(key_listorti)

    assert user_pepe = user_pepe_2
    assert user_jose = user_jose_2
    assert user_maria = user_maria_2
    assert user_listorti = user_listorti_2
  end

  test "Crear user en varios nodos sin repetir" do
    key = "Pepe"

    instances_before = length(get_user_instances(key))

    resultado = User.dnew(key)

    Process.sleep(5000)

    instances_after = length(get_user_instances(key))

    difference = instances_after - instances_before

    assert instances_before<=Pigeon.Process.get_max_instances()
    assert difference>=0
  end

  def get_user_instances(name) do
    children_pids = Enum.map(HDS.which_children(Horde), fn {_, pid, _, _} -> pid end)

    :logger.debug("CHILDREN PIDS: #{inspect children_pids}")

    Enum.filter(children_pids, fn  pid -> User.name(pid)==name  end)
  end


  def get_random_node do
    nodes_to_choose =["pigeon@10.0.0.2","pigeon@10.0.0.3","pigeon@10.0.0.4"]# Enum.filter(["pigeon@10.0.0.2","pigeon@10.0.0.3","pigeon@10.0.0.4"],fn n-> !(n=="Node.self) end)
    Enum.random(nodes_to_choose)
  end

end
