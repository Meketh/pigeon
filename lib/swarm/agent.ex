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

      def task(id, fun, args, seconds) do
        Swarm.Task.register(id,
          __MODULE__, fun, args,
          :os.system_time + seconds * 1_000_000_000)
      end

      # Swarm.Callbacks / Handoff: :restart | :ignore | {:resume, handoff}
      def handle_call({:swarm, :begin_handoff}, _from, state), do: {:reply, :restart, state}
      def handle_cast({:swarm, :end_handoff, _handoff}, state), do: {:noreply, state}
      def handle_cast({:swarm, :resolve_conflict, _conflict}, state), do: {:noreply, state}
      def handle_info({:swarm, :die}, state), do: {:stop, :shutdown, state}
    end
  end
end
