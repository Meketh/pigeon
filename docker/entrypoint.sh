export HOSTIP=$(hostname -i)
export COOKIE="cGlnZW9uLXNlY3JldC1jb29raWU="
cmd="elixir --name pigeon@$HOSTIP --cookie $COOKIE --no-halt -S mix $MIX_CMD"
# sh -c "$cmd"
while true; do
  ag -g "(?:.ex$)|(?:.exs$)" | entr -drs "$cmd"
done
