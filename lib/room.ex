defmodule Room do
  use GenServer
  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end


  # Callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_call({:send, msg}, _from, state) do
    {:reply,msg, state|>Map.replace(:msgs,[msg|state.msgs])}
  end

  def handle_call({:msg, value}, _from, state) do
    {:reply, value, state}
  end


end
