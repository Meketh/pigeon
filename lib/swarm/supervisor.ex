defmodule Swarm.Supervisor do
  @replicas Application.get_env(:pigeon, :replicas, 3)
  @timeout Application.get_env(:pigeon, :timeout, 5_000)
  use DynamicSupervisor
  alias DynamicSupervisor, as: DS
  def start_link(), do: DS.start_link(__MODULE__, nil, name: __MODULE__)
  def init(_), do: DS.init(strategy: :one_for_one)
  def start_child(child_spec), do: DS.start_child(__MODULE__, child_spec)

  def whereis(id), do: Swarm.whereis_name({id})
  def whereis(id, r), do: Swarm.whereis_name({id, r})
  def whereare(id), do: Enum.map(1..@replicas, &whereis(id, &1))
  def exists(id), do: whereis(id) != :undefined
  def exists(id, r), do: whereis(id, r) != :undefined
  def replicated(id), do: Enum.any?(1..@replicas, &exists(id, &1))

  def via(id), do: {:via, :swarm, id}
  def call_any(id, msg), do: do_any(:call, id, 1, msg)
  def cast_any(id, msg), do: do_any(:cast, id, 1, msg)

  def replicate(%{id: id} = child_spec) do
    if replicated(id) do
      {:error, :already_registered}
    else
      replicas = for r <- 1..@replicas do
        child_spec.id
        |> put_in({id, r})
        |> do_register()
      end
      if Enum.all?(replicas, &match?({:ok, _}, &1)),
      do: {:ok, child_spec.id},
      else: {:error, replicas}
    end
  end
  def unreplicate(id) do
    for r <- 1..@replicas,
    do: do_unregister({id, r})
  end
  def unregister(id), do: do_unregister({id})
  def register(%{id: id} = child_spec) do
    child_spec.id
    |> put_in({id})
    |> do_register()
  end

  defp do_unregister(id), do: Swarm.unregister_name(id)
  defp do_register(child_spec) do
    Swarm.register_name(child_spec.id,
      Swarm.Supervisor, :start_child, [child_spec], @timeout)
  end

  defp do_any(act, idr, msg, error \\ :replica_not_found)
  defp do_any(_, _, r, _, error) when r < 1 or @replicas < r do
    {:error, error}
  end
  defp do_any(act, id, r, msg, error) do
    if exists(id) do
      try do
        apply(GenServer, act, [via({id, r}), msg])
      catch
        :exit, error -> do_any(act, id, (r+1), msg, error)
      end
    else
      do_any(act, id, (r+1), msg, error)
    end
  end
end
