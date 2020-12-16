# VIEWS
#   register(user, pass, name \\ user) -> {:exists}
#   login(user, pass) -> {:missmatch}
#   main -> chats con unreads
#     {/new, /group, /pm} -> {:not_found}
#   chat -> last X msgs or from unread
#     {:up, :down, :page_up, :page_down, :end, :enter, :esc, :back}

defmodule Cli do
  @behaviour Ratatouille.App
  import Ratatouille.View
  import Ratatouille.Constants
  # @up key(:arrow_up)
  # @down key(:arrow_down)
  # @left key(:arrow_left)
  # @right key(:arrow_right)
  # @arrows [@up, @down, @left, @right]
  # @space key(:space)
  # @back key(:backspace)
  # @delete key(:delete)
  @esc key(:esc)
  defstruct [:user, page: :home]
  def run(), do: Ratatouille.run(Cli, quit_events: [{:key, @esc}])
  def init(_context), do: %Cli{}
  # defp clear(), do: IO.puts("\e[H\e[2J")
  # defp main_view(user) do
  #   IO.gets("> ")
  #   |> String.trim
  #   |> case do
  #     "exit" -> clear()
  #     text ->
  #       IO.puts(String.upcase text)
  #       main_view(user)
  #   end
  # end
  def update(%{page: :home} = state, msg) do
    case msg do
      {:event, %{ch: ?+}} -> put_in(state.user, Pepe)
      _ -> state
    end
  end
  # listen msgs on all chats
  # unseen = listened + Chat.count(id, from(last_seen), to(first_listened))
  # add %Group{last_seen}
  # def join(id), do: Swarm.join({Chat, id}, self())
  # def leave(id), do: Swarm.join({Chat, id}, self())
  def render(%{page: :home} = state) do
    view do
      label(content: "Counter is #{state.user}")
      label do
        text(content: "R", color: :red)
        text(content: "G", color: :green)
        text(content: "B", color: :blue)
      end
      row do
        column size: 12 do
          panel title: "Left Column" do
            label(content: "Text on the left")
          end
        end
      end
    end
  end
end
# {:event, %{key: @del}} -> String.slice(model, 0..-2)
# {:event, %{key: @spacebar}} -> model <> " "
# {:event, %{ch: ch}} when ch > 0 -> model <> <<ch::utf8>>
