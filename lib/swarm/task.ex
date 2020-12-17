defmodule Swarm.Task do
  use Task
  alias Swarm.Supervisor, as: SS
  def child_spec(args) do
    %{id: __MODULE__, restart: :transient,
    start: {__MODULE__, :start_link, args}}
  end

  def register(id, m, f, a, t \\ 0) do
    SS.unregister(id)
    unless t == :infinity,
    do: SS.register(child_spec([m, f, a, t]))
  end
  def register(id, f, t \\ 0) do
    SS.unregister(id)
    unless t == :infinity,
    do: SS.register(child_spec([f, t]))
  end

  def start_link(m, f, a, t \\ 0) do
    unless t == :infinity,
    do: Task.start_link(__MODULE__, :run, [m, f, a, t])
  end
  def start_link(f, t \\ 0) do
    unless t == :infinity,
    do: Task.start_link(__MODULE__, :run, [f, t])
  end

  def run(m, f, a, t \\ 0) do
    wait(t)
    apply(m, f, a)
  end
  def run(f, t \\ 0) do
    wait(t)
    apply(f, [])
  end

  def wait(t) do
    d = t - :os.system_time(:seconds)
    IO.inspect(d)
    unless d < 0, do: Process.sleep(d * 1000)
  end
end
