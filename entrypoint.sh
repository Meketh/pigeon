COOKIE="--cookie cGlnZW9uLXNlY3JldC1jb29raWU="
watch_cmd() {
  while true; do
    ag -g "(?:.ex$)|(?:.exs$)" | entr -drs "elixir $1"
  done
}
if [ "$2" = "" ]; then # Docker
  export MIX_ENV=docker
  watch_cmd "$COOKIE --name pigeon@$(hostname -i) -S mix run --no-halt"
else # Localhost
  export NODE_IPS="$1"
  if [ "$2" = "test" ]; then
    watch_cmd "-S mix test --no-start $3"
  elif [ "$2" = "cli" ]; then
    sh -c "iex $COOKIE --sname cli-$(date +%s%N) --remsh pigeon@0.0.0.0"
  else
    export MIX_ENV=prod
    sh -c "iex $COOKIE --name pigeon@0.0.0.0 -S mix $2 --no-halt"
  fi
fi
