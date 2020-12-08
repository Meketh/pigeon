defmodule State.Distribution do
  @behaviour Horde.DistributionStrategy
  def has_quorum?(_members), do: true

  def get_chosen_member(identifier,members) do
    c=HashRing.new()
    |> HashRing.add_nodes(Map.keys(members))
    |> HashRing.key_to_node(identifier)
    c
  end

  def choose_node(child_spec, members) do
    identifier = :erlang.phash2(Map.drop(child_spec, [:id]))

    # proxy_to_node(other_node_name, msg, from, state)

    start_spec = Map.get(child_spec, :start)

    :logger.debug("Horde spec: #{inspect(child_spec)}, members: #{inspect(members)}")
    :logger.debug("Horde ID: #{inspect(identifier)}")

    members
    |> Enum.filter(&match?(%{status: :alive}, &1))
    |> Map.new(fn member -> {member.name, member} end)
    |> case do
      members when map_size(members) == 0 ->
        {:error, :no_alive_nodes}

      members ->{:ok, Map.get(members, State.Distribution.get_chosen_member(identifier,members))}
        # chosen_member = HashRing.new()
        # |> HashRing.add_nodes(Map.keys(members))
        # |> HashRing.key_to_node(identifier)
        # {:ok, Map.get(members, chosen_member)}
    end
  end
end
