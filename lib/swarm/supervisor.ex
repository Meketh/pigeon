defmodule Swarm.Supervisor do
  @replicas Application.get_env(:pigeon, :replicas, 3)
  use DynamicSupervisor
  alias DynamicSupervisor, as: DS
  def start_link(), do: DS.start_link(__MODULE__, nil, name: __MODULE__)
  def init(_), do: DS.init(strategy: :one_for_one)
  def start_child(child_spec), do: DS.start_child(__MODULE__, child_spec)

  def via(id), do: {:via, :swarm, id}

  def childs(), do: Swarm.registered()
  def whereis(id), do: Swarm.whereis_name(id)
  def exists(id), do: whereis(id) != :undefined
  def replicated(id), do: 1..@replicas
    |> Enum.any?(&exists(%{id: id, replica: &1}))

  def replicate(%{id: id} = child_spec) do
    if replicated(id) do
      {:error, :already_registered}
    else
      for r <- 1..@replicas do
        child_spec.id
        |> put_in(%{id: id, replica: r})
        |> register()
      end
      {:ok, child_spec.id}
    end
  end

  def register(child_spec) do
    Swarm.register_name(child_spec.id,
      Swarm.Supervisor, :start_child, [child_spec], 5_000)
  end

  def unregister(id) do
    Swarm.unregister_name(id)
  end
end
