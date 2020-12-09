# defmodule Agenda do
#   use Agent
#   def key(name), do: {__MODULE__, name, 0}
#   def start_link(_name) do
#     Agent.start_link(fn -> %{} end)
#   end
#   def add(name, contact) do
#     Agent.update(via(name), &Map.put(&1, contact, 0))
#   end
#   def get(name) do
#     Agent.get(via(name), __MODULE__, :do_get, [])
#   end
#   def do_get(state), do: {state}
# end
