defmodule Swarm.Agent do
  alias Swarm.Supervisor, as: SS
  def exists(id), do: SS.replicated(id)
  def replicate(id, stores), do: SS.replicate(child_spec(id, stores))
  def dereplicate(id), do: SS.dereplicate(id)

  def child_spec(id, stores) do
    %{id: id, type: :supervisor, restart: :transient,
    start: {__MODULE__, :start_link, [id, stores]}}
  end
  def start_link(id, stores) do
    GenServer.start_link(Swarm.Agent.Server, {id, stores})
  end

  def set_all(id, path, value), do: Swarm.multi_call(id, {:get, path, value})
  def get_all(id, path), do: Swarm.multi_call(id, {:get, path})
  def get_all(id, path, fun), do: Swarm.multi_call(id, {:get, path, fun})
  def get_and_update_all(id, fun), do: Swarm.multi_call(id, {:get_and_update, fun})
  def get_and_update_all(id, path, fun), do: Swarm.multi_call(id, {:get_and_update, path, fun})
  def update_all(id, fun), do: Swarm.multi_call(id, {:update, fun})
  def update_all(id, path, fun), do: Swarm.multi_call(id, {:update, path, fun})
  def cast_all(id, fun), do: Swarm.publish(id, {:cast, fun})
  def cast_all(id, path, fun), do: Swarm.publish(id, {:cast, path, fun})

  def set(id, path, value), do: SS.call_any(id, {:set, path, value})
  def get(id, path), do: SS.call_any(id, {:get, path})
  def get(id, path, fun), do: SS.call_any(id, {:get, path, fun})
  def get_and_update(id, fun), do: SS.call_any(id, {:get_and_update, fun})
  def get_and_update(id, path, fun), do: SS.call_any(id, {:get_and_update, path, fun})
  def update(id, fun), do: SS.call_any(id, {:update, fun})
  def update(id, path, fun), do: SS.call_any(id, {:update, path, fun})
  def cast(id, fun), do: SS.cast_any(id, {:cast, fun})
  def cast(id, path, fun), do: SS.cast_any(id, {:cast, path, fun})

  defmacro __using__(_opts) do
    quote do
      alias Swarm.Agent, as: SA
      def mfa(fun, args), do: {__MODULE__, fun, args}
      def group(id), do: {__MODULE__, id}
      def exists(id), do: SA.exists(group(id))
      def replicate(id, stores), do: SA.replicate(group(id), stores)
      def dereplicate(id), do: SA.dereplicate(group(id))

      def set_all(id, path, value), do: SA.set_all(group(id), path, value)
      def get_all(id, path), do: SA.get_all(group(id), path)
      def get_all(id, path, fun), do: SA.get_all(group(id), path, fun)
      def get_and_update_all(id, fun), do: SA.get_and_update_all(group(id), fun)
      def get_and_update_all(id, path, fun), do: SA.get_and_update_all(group(id), path, fun)
      def update_all(id, fun), do: SA.update_all(group(id), fun)
      def update_all(id, path, fun), do: SA.update_all(group(id), path, fun)
      def cast_all(id, fun), do: SA.cast_all(group(id), fun)
      def cast_all(id, path, fun), do: SA.cast_all(group(id), path, fun)

      def set(id, path, value), do: SA.set(group(id), path, value)
      def get(id, path), do: SA.get(group(id), path)
      def get(id, path, fun), do: SA.get(group(id), path, fun)
      def get_and_update(id, fun), do: SA.get_and_update(group(id), fun)
      def get_and_update(id, path, fun), do: SA.get_and_update(id, path, fun)
      def update(id, fun), do: SA.update(group(id), fun)
      def update(id, path, fun), do: SA.update(group(id), path, fun)
      def cast(id, fun), do: SA.cast(group(id), fun)
      def cast(id, path, fun), do: SA.cast(group(id), path, fun)
    end
  end
end
