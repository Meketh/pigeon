defmodule Chat.Utils do
  def add_msg(chat, sender, text) do
    %{chat | messages: List.insert_at(chat.messages, -1, %{id: UUID.uuid1(), date: DateTime.utc_now(), sender: sender, message: text})}
  end

  def delete_msg(chat, messageid) do
    index = Enum.find_index(chat.messages, fn msg -> msg.id == messageid end)
    %{chat | messages: List.delete_at(chat.messages,index)}
  end

  def update_msg(chat, messageid, new_text) do
    index = Enum.find_index(chat.messages, fn msg -> msg.id == messageid end)
    %{chat | messages: List.update_at(chat.messages, index, &(%{&1 | message: new_text, date: DateTime.utc_now()}))}
  end
end
