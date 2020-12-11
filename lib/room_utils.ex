defmodule Room.Utils do
  def new_room(creator, guest) do
    participants = [creator,guest]
    chatid = UUID.uuid3(:oid, participants)
    {:OK, chatid}
  end

  def members?(list,sublist) do
    Enum.all?(sublist, &Enum.member?(list, &1))
  end

  def add_administrators(chat, guests) do
    chat|>Map.replace(:admins,Enum.uniq(chat.admins++guests))
  end

  def remove_administrators(chat, guests) do
    chat|>Map.replace(:admins,Enum.uniq(chat.admins--guests))
  end

end
