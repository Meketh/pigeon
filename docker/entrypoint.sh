export HOSTIP=$(hostname -i)
export COOKIE="cGlnZW9uLXNlY3JldC1jb29raWU="
if [ "$2" = "" ]; then
  cmd="--name pigeon@$HOSTIP --cookie $COOKIE --no-halt -S mix run"
else
  export NODE_IPS="$1"
  cmd="--name pigeon@0.0.0.0 --cookie $COOKIE --no-halt -S mix $2"
  if [ "$2" = "run" ]; then
    sh -c "iex $cmd"
    exit 0
  fi
fi
while true; do
  ag -g "(?:.ex$)|(?:.exs$)" | entr -drs "elixir $cmd"
done
