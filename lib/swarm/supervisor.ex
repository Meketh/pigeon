defmodule Swarm.Supervisor do
  @replicas Application.get_env(:pigeon, :replicas, 3)
  @timeout Application.get_env(:pigeon, :timeout, 5_000)
  use DynamicSupervisor
  alias DynamicSupervisor, as: DS
  def start_link(), do: DS.start_link(__MODULE__, nil, name: __MODULE__)
  def init(_), do: DS.init(strategy: :one_for_one)
  def count_children(), do: DS.count_children(__MODULE__)
  def start_child(child_spec), do: DS.start_child(__MODULE__, child_spec)
  def stop_child(child_id), do: DS.terminate_child(__MODULE__, child_id)

  def whereis(id), do: Swarm.whereis_name({id})
  def whereis(id, r), do: Swarm.whereis_name({id, r})
  def whereare(id), do: Enum.map(1..@replicas, &whereis(id, &1))
  def exists(id), do: whereis(id) != :undefined
  def exists(id, r), do: whereis(id, r) != :undefined
  def replicated(id), do: Enum.any?(1..@replicas, &exists(id, &1))

  def via(id), do: {:via, :swarm, {id}}
  def via(id, r), do: {:via, :swarm, {id, r}}
  def do_any(mod, fun, id, args \\ []) do
    do_any(mod, fun, id, 1, args, :replica_not_found)
  end

  def unreplicate(id) do
    for r <- 1..@replicas,
    do: do_unregister({id, r})
  end
  def replicate(%{id: id} = child_spec) do
    if replicated(id) do
      {:error, :already_registered}
    else
      replicas = for r <- 1..@replicas do
        child_spec
        |> put_in([:id], {id, r})
        |> update_in([:start], fn{m, f, a}->{m, f, [id, r | a]}end)
        |> do_register()
      end
      if Enum.all?(replicas, &match?({:ok, _}, &1)),
      do: {:ok, child_spec.id},
      else: {:error, replicas}
    end
  end
  def replicate(mod, args \\ []) do
    apply(mod, :child_spec, [args])
    |> replicate()
  end

  def unregister(id), do: do_unregister({id})
  def register(%{id: id} = child_spec) do
    child_spec
    |> put_in([:id], {id})
    |> do_register()
  end
  def register(mod, args \\ []) do
    apply(mod, :child_spec, [args])
    |> register()
  end

  defp do_unregister(id), do: Swarm.unregister_name(id)
  defp do_register(child_spec) do
    Swarm.register_name(child_spec.id,
      Swarm.Supervisor, :start_child, [child_spec], @timeout)
  end

  defp do_any(_, _,  _, r, _, error) when @replicas < r, do: {:error, error}
  defp do_any(m, f, id, r, a, error) do
    if exists(id, r) do
      try do
        apply(m, f, [via(id, r) | a])
      catch
        :exit, error -> do_any(m, f, id, (r+1), a, error)
      end
    else
      do_any(m, f, id, (r+1), a, error)
    end
  end
end
