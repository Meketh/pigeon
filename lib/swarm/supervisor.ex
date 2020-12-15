defmodule Swarm.Supervisor do
  @replicas Application.get_env(:pigeon, :replicas, 3)
  @timeout Application.get_env(:pigeon, :timeout, 5_000)
  use DynamicSupervisor
  alias DynamicSupervisor, as: DS
  def start_link(), do: DS.start_link(__MODULE__, nil, name: __MODULE__)
  def init(_), do: DS.init(strategy: :one_for_one)
  def start_child(child_spec), do: DS.start_child(__MODULE__, child_spec)

  def whereis(id), do: Swarm.whereis_name(id)
  def whereare(id), do: 1..@replicas
    |> Enum.map(&whereis(%{id: id, replica: &1}))
  def exists(id), do: whereis(id) != :undefined
  def replicated(id), do: 1..@replicas
    |> Enum.any?(&exists(%{id: id, replica: &1}))

  def replicate(%{id: id} = child_spec) do
    if replicated(id) do
      {:error, :already_registered}
    else
      replicas = for r <- 1..@replicas do
        child_spec.id
        |> put_in(%{id: id, replica: r})
        |> register()
      end
      if Enum.all?(replicas, &match?({:ok, _}, &1)),
      do: {:ok, child_spec.id},
      else: {:error, replicas}
    end
  end
  def dereplicate(id) do
    for r <- 1..@replicas do
      unregister(%{id: id, replica: r})
    end
  end

  def register(child_spec) do
    Swarm.register_name(child_spec.id,
      Swarm.Supervisor, :start_child, [child_spec], @timeout)
  end
  def unregister(id) do
    Swarm.unregister_name(id)
  end

  def via(id), do: {:via, :swarm, id}
  # def call_all(id, msg) do
  #   for r <- 1..@replicas do
  #     try do
  #       via = via(%{id: id, replica: r})
  #       if Process.alive?(via) do
  #         GenServer.call(via, msg)
  #       end
  #     catch
  #       :exit, _ -> nil
  #     end
  #   end
  # end
  def call_any(id, msg) do
    do_any(&GenServer.call/2, %{id: id, replica: 1}, msg)
  end
  def cast_any(id, msg) do
    do_any(&GenServer.cast/2, %{id: id, replica: 1}, msg)
  end

  defp do_any(act, id, msg, error \\ :replica_not_found)
  defp do_any(_, %{replica: rep}, _, error)
  when rep < 1 or @replicas < rep do
    {:error, error}
  end
  defp do_any(act, id, msg, error) do
    next_id = update_in(id, [:replica], &(&1 + 1))
    if exists(id) do
      case act.(via(id), msg) do
        {:error, error} -> do_any(act, next_id, msg, error)
        reply -> reply
      end
    else
      do_any(act, next_id, msg, error)
    end
  end
end
