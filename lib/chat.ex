defmodule Msg do
  defstruct [:sender, :text,
    id: Nanoid.generate(),
    created: :os.system_time,
    updated: :os.system_time]
end

defmodule Chat do
  use Cluster.Agent

  defstruct [:name, members: %{}, msgs: []]
  def msgs(chat, 0), do: chat.msgs
  def msgs(chat, from), do: chat.msgs |> Enum.filter(&(&1.updated > from))
  def count(chat, from), do: msgs(chat, from) |> Enum.count()

  def init(name) do
    # join_events(name, events)
    {:ok, %Chat{name: name}}
  end

  # def get_msgs(name, from \\ 0), do: get(name, :msgs, [from])
  # def get_count(name, from \\ 0), do: get(name, :count, [from])

  def handle_info({{_name, :add}, {id, msg}}, state) do
    {:noreply, put_in(state.msgs[id], msg)}
  end
  def handle_info({{_name, :del}, ids}, state) do
    {:noreply, update_in(state, [:msgs], &Map.drop(&1, ids))}
  end
  def handle_info({{_name, :mod}, {id, text}}, state) do
    {:noreply, update_in(state, [:msgs, id, :text], text)}
  end
  def handle_info({{_name, :ttl}, ttls}, state) do
    {:noreply, for {id, ttl} <- ttls do
      update_in(state, [:msgs, id, :ttl], ttl)
    end}
  end
end
