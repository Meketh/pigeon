defmodule Swarm.Agent do
  alias Swarm.Supervisor, as: SS
  defmacro __using__(_opts) do
    quote do
      use GenServer
      def start_link(id, ops \\ []) do
        GenServer.start_link(__MODULE__, id, ops)
      end

      def init(id), do: {:ok, id, {:continue, :init}}
      def handle_continue(:init, id) do
        Swarm.join(group(id), self())
        {:noreply, {0, on_init(id)}}
      end
      def on_init(id), do: %{id: id}
      defoverridable on_init: 1

      def group(id), do: {__MODULE__, id}
      def exists(id), do: SS.replicated(group(id))
      def new(id), do: SS.replicate(child_spec(id))
      def child_spec(id) do
        %{id: group(id),
        shutdown: 10_000,
        restart: :transient,
        start: {__MODULE__, :start_link, [id]}}
      end

      def emit(id, event, data) do
        Swarm.publish(group(id), {:event, event, data})
      end
      def handle_info({:event, event, data}, {_, state}) do
        {:noreply, {:os.system_time, handle_event(state, event, data)}}
      end
      def handle_event(state, _, _), do: state
      defoverridable handle_event: 3

      def fetch(id, request) do
        for {time, response} <- Swarm.multi_call(
          group(id), {:fetch, request}),
        reduce: {0, nil} do
          {max_time, _} when max_time < time -> {time, response}
          max -> max
        end |> elem(1)
      end
      def handle_call({:fetch, request}, _from, {time, state}) do
        {:reply, {time, handle_fetch(state, request)}, {time, state}}
      end
      def handle_fetch(state, _), do: state
      defoverridable handle_fetch: 2
      # def join(id, group), do: Swarm.join({__MODULE__, id, group}, self())
      # def leave(id, group), do: Swarm.join({__MODULE__, id, group}, self())

      # Agent
      # def cast(id, fun, args \\ []), do: Agent.cast(via(id), __MODULE__, fun, args)
      # def handle_cast({:cast, fun}, state), do: {:noreply, run(fun, [state])}

      # def get(id, fun, args \\ []), do: Agent.get(via(id), __MODULE__, fun, args)
      # def handle_call({:get, fun}, _from, state), do: {:reply, run(fun, [state]), state}

      # def update(id, fun, args \\ []), do: Agent.update(via(id), __MODULE__, fun, args)
      # def handle_call({:update, fun}, _from, state), do: {:reply, :ok, run(fun, [state])}

      # def get_and_update(id, fun, args \\ []), do: Agent.get_and_update(via(id), __MODULE__, fun, args)
      # def handle_call({:get_and_update, fun}, _from, state) do
      #   case run(fun, [state]) do
      #     {reply, state} -> {:reply, reply, state}
      #     {reply} -> {:reply, reply, state}
      #     other -> {:stop, {:bad_return_value, other}, state}
      #   end
      # end

      # defp run({m, f, a}, extra), do: apply(m, f, extra ++ a)
      # defp run(fun, extra), do: apply(fun, extra)

      # Swarm.Callbacks / Handoff: :restart | :ignore | {:resume, handoff}
      def handle_call({:swarm, :begin_handoff}, _from, state), do: {:reply, :restart, state}
      def handle_cast({:swarm, :end_handoff, _handoff}, state), do: {:noreply, state}
      def handle_cast({:swarm, :resolve_conflict, _conflict}, state), do: {:noreply, state}
      def handle_info({:swarm, :die}, state), do: {:stop, :shutdown, state}
    end
  end
end
