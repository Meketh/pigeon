# defmodule Chat do
#   use Swarm.Agent, [:name, members: %{}, msgs: %{}]
#   def handle_conflict(other, self) do
#     super(other, self)
#     |> put_in([:members],
#       Map.merge(self.members, other.members, fn({ta, va}, {tb, vb})->
#         if ta > tb do {ta, va} else {tb, vb} end
#       end))
#     |> put_in([:msgs], Map.merge(self.msgs, other.msgs, super)
#   end

#   # fetch
#   def members(id), do: fetch(id, :members)
#   def msgs(id), do: fetch(id, :msgs)
#   def msgs(id, from, to \\ :infinity), do: fetch(id, {:msgs, from, to})
#   def count(id, from, to \\ :infinity), do: fetch(id, {:count, from, to})
#   def past_msgs(id, from, count), do: fetch(id, {:past_msgs, from, count})

#   # handle_fetch
#   def handle_fetch(state, :members) do
#     for {k, {_, v}} <- state.members,
#     into: %{}, do: {k, v}
#   end
#   def handle_fetch(state, :msgs), do: state.msgs
#   def handle_fetch(state, {:msgs, from, to}) do
#     state.msgs
#     |> Enum.map(fn{_, msg}-> msg end)
#     |> Enum.filter(&(from <= &1.created and &1.created <= to))
#   end
#   def handle_fetch(state, {:count, from, to}) do
#     handle_fetch(state, {:msgs, from, to})
#     |> Enum.count()
#   end
#   def handle_fetch(state, {:past_msgs, from, count}) do
#     state.msgs
#     |> Enum.map(fn{_, msg}-> msg end)
#     |> Enum.filter(&(&1.created <= from))
#     |> Enum.sort(&(&1.created > &2.created))
#     |> Enum.take(count)
#   end

#   # emit
#   def join(id, user, role \\ :member), do: emit(id, :join, {user, role})
#   def leave(id, user), do: emit(id, :leave, user)
#   def msg(id, sender, text) do
#     emit(id, :msg, Msg.new(sender, text))
#   end
#   def mod(id, sender, msg_id, text) do
#     emit(id, :mod, {sender, msg_id, text})
#   end
#   def del(id, sender, from, to), do: emit(id, :del, {sender, from, to})
#   def del(id, sender, ids), do: emit(id, :del, {sender, ids})

#   # handle_event
#   def handle_event(state, :join, {user, role}) do
#     put_in(state.members[user], {:os.system_time, role})
#   end
#   def handle_event(state, :leave, user) do
#     msg = Msg.new(:system, "*************** #{user} left ***************")
#     put_in(state.members[user], {:os.system_time, :leave})
#     |> put_in([:msgs, msg.id], msg)
#   end
#   def handle_event(state, :msg, %{id: id} = msg) do
#     put_in(state.msgs[id], msg)
#   end
#   def handle_event(state, :mod, {sender, msg_id, text}) do
#     if sender?(state, sender, msg_id)
#     do update_in(state, [:msgs, msg_id, ], &(%{&1|
#       text: text, updated: :os.system_time
#     }))
#     else state end
#   end

#   def handle_event(state, :del, {sender, from, to}) do
#     {from, to} = get_times(state, from, to)
#     for msg <- state.msgs, reduce: state do
#       state ->
#         if from <= msg.created and msg.created <= to
#         do del_msg(state, sender, msg.id)
#         else state end
#     end
#   end
#   def handle_event(state, :del, {sender, ids}) do
#     for id <- ids, reduce: state do
#       state -> del_msg(state, sender, id)
#     end
#   end

#   # task
#   def ttl(id, sender, from, to, ttl) do
#     task({:ttl, id}, :del, [id, sender, from, to], ttl)
#   end
#   def ttl(id, sender, ids, ttl) do
#     task({:ttl, id}, :del, [id, sender, ids], ttl)
#   end

#   # private
#   defp sender?(state, sender, msg_id) do
#     get_in(state, [:msgs, msg_id, :sender]) == sender
#   end
#   defp del_msg(state, sender, msg_id) do
#     if sender?(state, sender, msg_id)
#     do update_in(state, [:msgs, msg_id], &(%{&1|
#       text: :deleted, updated: :os.system_time
#     }))
#     else state end
#   end

#   defp get_times(state, from, to) do
#     {get_time(state, from, 0),
#     get_time(state, to, :infinity)}
#   end
#   defp get_time(state, id, default) do
#     case get_in(state, [:msgs, id, :time]) do
#       nil -> default
#       time -> time
#     end
#   end
# end
