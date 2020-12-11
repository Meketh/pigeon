defmodule Chat do
  use Swarm.Agent
  defstruct [:id, :name, members: %{}, msgs: %{}]
  defmodule Msg do
    defstruct [:sender, :text,
      id: Nanoid.generate(),
      time: :os.system_time]
  end
  def on_init(id), do: %Chat{id: id}
  # fetch
  def members(id), do: fetch(id, :members)
  def msgs(id), do: fetch(id, :msgs)
  def msgs(id, from, to \\ :infinity), do: fetch(id, {:msgs, from, to})
  def count(id, from, to \\ :infinity), do: fetch(id, {:count, from, to})
  def past_msgs(id, from, count), do: fetch(id, {:past_msgs, from, count})
  # handle_fetch
  def handle_fetch(state, :members), do: state.members
  def handle_fetch(state, :msgs), do: state.msgs
  def handle_fetch(state, {:msgs, from, to}) do
    state.msgs
    |> Enum.map(fn{_, msg}-> msg end)
    |> Enum.filter(&(from <= &1.time and &1.time <= to))
  end
  def handle_fetch(state, {:count, from, to}) do
    handle_fetch(state, {:msgs, from, to})
    |> Enum.count()
  end
  def handle_fetch(state, {:past_msgs, from, count}) do
    state.msgs
    |> Enum.map(fn{_, msg}-> msg end)
    |> Enum.filter(&(&1.time <= from))
    |> Enum.sort(&(&1.time > &2.time))
    |> Enum.take(count)
  end
  # emit
  def join(id, user, role \\ :member), do: emit(id, :join, {user, role})
  def leave(id, user), do: emit(id, :leave, user)
  def msg(id, sender, text) do
    emit(id, :msg, %Msg{sender: sender, text: text})
  end
  def mod(id, msg_id, text), do: emit(id, :mod, {msg_id, text})
  def del(id, from, to), do: emit(id, :del, {from, to})
  def del(id, ids), do: emit(id, :del, ids)
  # handle_event
  def handle_event(state, :join, {user, role}) do
    put_in(state.members[user], role)
  end
  def handle_event(state, :leave, user) do
    update_in(state, [:members], &Map.drop(&1, [user]))
  end
  def handle_event(state, :msg, %{id: id} = msg) do
    put_in(state.msgs[id], msg)
  end
  def handle_event(state, :mod, {id, text}) do
    put_in(state.msgs[id].text, text)
  end

  def handle_event(state, :del, {from, to}) do
    {from, to} = get_times(state, from, to)
    for msg <- state.msgs, reduce: state do
      state -> if from <= msg.time and msg.time <= to do
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
