COOKIE="--cookie cGlnZW9uLXNlY3JldC1jb29raWU="
watch_cmd() {
  while true; do
    ag -g "(?:.ex$)|(?:.exs$)" | entr -drs "elixir $1"
  done
}
if [ "$2" = "" ]; then
  watch_cmd "$COOKIE --name pigeon@$(hostname -i) -S mix run"
else
  export NODE_IPS="$1"
  if [ "$2" = "test" ]; then
    watch_cmd "$COOKIE --name pigeon@0.0.0.0 -S mix test"
  elif [ "$2" = "cli" ]; then
    sh -c "iex $COOKIE --name cli-$(date +%s%N)@$(date +%s%N) --remsh pigeon@0.0.0.0"
  else
    export MIX_ENV=prod
    sh -c "iex $COOKIE --name pigeon@0.0.0.0 -S mix $2"
  fi
fi
