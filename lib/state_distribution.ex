defmodule State.Distribution do
  @behaviour Horde.DistributionStrategy
  def has_quorum?(_members), do: true
  def choose_node(identifier, members) do
    :logger.debug("Horde ID: #{inspect identifier}")
    members
    |> Enum.filter(&match?(%{status: :alive}, &1))
    |> Map.new(fn member -> {member.name, member} end)
    |> case do
      members when map_size(members) == 0 ->
        {:error, :no_alive_nodes}
      members ->
        chosen_member = HashRing.new()
          |> HashRing.add_nodes(Map.keys(members))
          |> HashRing.key_to_node(identifier)
        {:ok, Map.get(members, chosen_member)}
    end
  end
end
