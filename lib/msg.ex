# defmodule Msg do
#   defstruct [:sender, :text,
#     id: Nanoid.generate(),
#     created: :os.system_time]

#   def new(sender, text) do
#     %Msg{id: Nanoid.generate(),
#       sender: sender, text: text,
#       created: :os.system_time}
#   end
# end
