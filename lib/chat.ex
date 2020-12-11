defmodule Msg do
  defstruct [:sender, :text,
    id: Nanoid.generate(),
    time: :os.system_time]
end

defmodule Chat do
  use Swarm.Agent
  defstruct [:id, members: %{}, msgs: %{}]
  def on_init(id), do: {:ok, %Chat{id: id}}

  def msgs(id), do: fetch(id, :msgs)
  def msgs(id, from, to), do: fetch(id, {:msgs, from, to})

  def handle_fetch(state, :msgs), do: state.msgs
  def handle_fetch(state, {:msgs, from, to}) do
    {from, to} = get_times(state, from, to)
    for msg <- state.msgs,
    from <= msg.time,
    msg.time <= to,
    do: msg
  end

  def add(id, msg), do: emit(id, :add, msg)
  def mod(id, msg_id, text), do: emit(id, :mod, {msg_id, text})
  def del(id, from, to), do: emit(id, :del, {from, to})
  def del(id, ids), do: emit(id, :del, ids)

  def handle_event(state, :add, %{id: id} = msg) do
    put_in(state.msgs[id], msg)
  end
  def handle_event(state, :mod, {id, text}) do
    put_in(state.msgs[id].text, text)
  end

  def handle_event(state, :del, {from, to}) do
    {from, to} = get_times(state, from, to)
    for msg <- state.msgs, reduce: state do
      state -> if from <= msg.time and msg.time do
        update_in(state, [:msgs, msg.id], &put_in(&1.text, :deleted))
      else state end
    end
  end
  def handle_event(state, :del, ids) do
    for id <- ids, reduce: state do
      state -> update_in(state, [:msgs, id], &put_in(&1.text, :deleted))
    end
  end

  defp get_times(state, from, to) do
    {get_time(state, from, 0),
    get_time(state, to, :infinity)}
  end
  defp get_time(state, id, default) do
    case get_in(state, [:msgs, id, :time]) do
      nil -> default
      time -> time
    end
  end
end
