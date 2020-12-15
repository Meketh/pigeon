defmodule Swarm.Agent.Server do
  use GenServer
  def init({id, stores}) do
    {:ok, sup} = Supervisor.start_link(
      Enum.map(stores, &Swarm.Agent.store_spec(id, &1)),
      strategy: :one_for_one)
    {:ok, {id, sup}, {:continue, :init}}
  end
  def handle_continue(:init, {id, sup}) do
    Swarm.join(id, self())
    {:noreply, {id, sup}}
  end

  def handle_call({:store, store}, _from, state) do
    {:reply, get_store(state, store), state}
  end
  def handle_call({:set, path, value}, _from, state) do
    update(state, path, fn _ ->{value}end)
    {:reply, :ok, state}
  end
  def handle_call({:get, path}, _from, state) do
    {:reply, get(state, path), state}
  end
  def handle_call({:get, path, fun}, _from, state) do
    {:reply, Util.run(fun, [get(state, path)]), state}
  end
  def handle_call({:get_and_update, fun}, _from, state) do
    {:reply, update(state, fun), state}
  end
  def handle_call({:get_and_update, path, fun}, _from, state) do
    {:reply, update(state, path, fun), state}
  end
  def handle_call({:update, fun}, _from, state) do
    fun = &({Util.run(fun, [&1])})
    {:reply, update(state, fun), state}
  end
  def handle_call({:update, path, fun}, _from, state) do
    fun = &({Util.run(fun, [&1])})
    {:reply, update(state, path, fun), state}
  end
  def handle_call({:swarm, :begin_handoff}, _from, state) do
    # Handoff: :restart | :ignore | {:resume, handoff}
    {:reply, :restart, state}
  end

  def handle_cast({:cast, fun}, state) do
    fun = &({Util.run(fun, [&1])})
    update(state, fun)
    {:noreply, state}
  end
  def handle_cast({:cast, path, fun}, state) do
    fun = &({Util.run(fun, [&1])})
    update(state, path, fun)
    {:noreply, state}
  end
  def handle_cast({:swarm, :end_handoff, _handoff}, state) do
    {:noreply, state}
  end
  def handle_cast({:swarm, :resolve_conflict, other}, state) do
    # DeltaCrdt.set_neighbours(n, neighbours)
    IO.inspect{other, state}
    {:noreply, state}
  end

  def handle_info({:cast, fun}, state) do
    handle_cast({:cast, fun}, state)
  end
  def handle_info({:cast, path, fun}, state) do
    handle_cast({:cast, path, fun}, state)
  end
  def handle_info({:swarm, :die}, state) do
    Process.sleep(1_000)
    {:stop, :shutdown, state}
  end

  # private
  defp get_store(state, store) do
    get_stores(state) |> get_in([store])
  end
  defp get_stores({_, sup}) do
    for {id, pid, _, _} <- Supervisor.which_children(sup),
      is_pid(pid), into: %{}, do: {id, pid}
  end

  defp read_stores(stores) do
    for {id, pid} <- stores, into: %{},
    do: {id, read_store(pid)}
  end
  defp read_store(nil), do: nil
  defp read_store(pid), do: DeltaCrdt.read(pid)

  defp get(state, []) do
    get_stores(state) |> read_stores()
  end
  defp get(state, [store]) do
    get_store(state, store) |> read_store()
  end
  defp get(state, [store | path]) do
    get(state, [store]) |> get_in(path)
  end

  defp update(state, [store, prop | path], fun) do
    pid = get_store(state, store)
    value = read_store(pid) |> get_in([prop])
    {reply, updates} = normalize_update(case path do
      [] -> Util.run(fun, [value])
      _ -> Util.run(fun, [get_in(value, path)])
    end)
    unless match?({{:error, :bad_return_value, _}, _}, reply),
    do: write_store(pid, prop, case path do
      [] -> updates
      _ -> put_in(value, path, updates)
    end)
    reply
  end
  defp update(state, [store], fun) do
    pid = get_store(state, store)
    {reply, updates} = Util.run(fun, [read_store(pid)])
      |> normalize_update()
    for {k, v} <- updates,
    do: write_store(pid, k, v)
    reply
  end
  defp update(state, [], fun), do: update(state, fun)
  defp update(state, fun) do
    stores = get_stores(state)
    {reply, updates} = Util.run(fun, [read_stores(stores)])
      |> normalize_update()
    for {id, values} <- updates do
      for {k, v} <- values,
      do: write_store(stores[id], k, v)
    end
    reply
  end
  defp normalize_update(updates) do
    case updates do
      {reply, updates} -> {reply, updates}
      {updates} -> {:ok, updates}
      other -> {{:error, :bad_return_value, other}, []}
    end
  end
  defp write_store(pid, prop, nil) do
    DeltaCrdt.mutate(pid, :remove, [prop])
  end
  defp write_store(pid, prop, value) do
    DeltaCrdt.mutate(pid, :add, [prop, value])
  end
end
