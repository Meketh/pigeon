defmodule Swarm.Agent do
  alias Swarm.Supervisor, as: SS
  defmacro __using__(_opts) do
    quote do
      use GenServer
      def start_link(id, ops \\ []) do
        GenServer.start_link(__MODULE__, id, ops)
      end

      def init(id) do
        {:ok, {0, id}, {:continue, :init}}
      end
      def handle_continue(:init, {0, id}) do
        replica = fetch(id, :state)
        # TODO: deadlock vs msg loss
        Swarm.join(group(id), self())
        {:noreply, {:os.system_time,
          if replica do replica
          else on_init(id) end}}
      end
      def handle_fetch(state, :state), do: state
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

      def task(id, fun, args, seconds) do
        Swarm.Task.register(id,
          __MODULE__, fun, args,
          :os.system_time + seconds * 1_000_000_000)
      end

      # Swarm.Callbacks
      def handle_call({:swarm, :begin_handoff}, _from, state) do
        # Handoff: :restart | :ignore | {:resume, handoff}
        {:reply, :restart, state}
      end
      def handle_cast({:swarm, :end_handoff, _handoff}, state) do
        {:noreply, state}
      end

      def handle_cast({:swarm, :resolve_conflict, other}, state) do
        {:noreply, handle_conflict(other, state)}
      end
      def handle_conflict(_, state), do: state
      defoverridable handle_conflict: 2

      def handle_info({:swarm, :die}, state) do
        {:stop, :shutdown, state}
      end
    end
  end
end
