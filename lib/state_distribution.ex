defmodule State.Distribution do
  @behaviour Horde.DistributionStrategy
  def has_quorum?(_members), do: true

  def get_node(name,nodes) do
    Enum.find(nodes,fn {_,n} -> "#{n}"=="#{name}" end)
  end

  def get_chosen_member(identifier,members) do

    :logger.debug("Members to choose: #{inspect(Map.keys(members))}")
    # c=HashRing.new()
    # |> HashRing.add_nodes(Map.keys(members))
    # |> HashRing.key_to_node(identifier)

    [_,_,chosen_node] = String.split(identifier, "_")

    :logger.debug("Name of chosen node: #{inspect(chosen_node)}")

    c = get_node(chosen_node,Map.keys(members))

    :logger.debug("Chosen Node: #{inspect(c)}")

    c
  end

  def choose_node(process_name, members) do
    # identifier = :erlang.phash2(Map.drop(child_spec, [:id]))


    # {_module,_method,params} = Map.get(child_spec, :start)

    # process_name = Map.get(child_spec, :id)

    :logger.debug("Horde ID: #{inspect(process_name)}")

    members
    |> Enum.filter(&match?(%{status: :alive}, &1))
    |> Map.new(fn member -> {member.name, member} end)
    |> case do
      members when map_size(members) == 0 ->
        {:error, :no_alive_nodes}

      members ->{:ok, Map.get(members, State.Distribution.get_chosen_member(process_name,members))}
        # chosen_member = HashRing.new()
        # |> HashRing.add_nodes(Map.keys(members))
        # |> HashRing.key_to_node(identifier)
        # {:ok, Map.get(members, chosen_member)}
    end
  end
end
