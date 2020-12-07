defmodule Chat do
  use GenServer
  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end


  # Callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_call({:get}, _from, state) do
    {:reply, state.user_id,state}
  end

end
