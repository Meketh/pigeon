import Config
config :nanoid, size: 7
config :logger, level: :error
config :pigeon, replicas: 3, timeout: 13_000
# config :logger, compile_time_purge_matching: [
#   # [module: Bar, function: "foo/3", level_lower_than: :error],
#   [application: :peerage],
#   [application: :swarm],
# ]

config :swarm, distribution_strategy: Swarm.Distribution, debug: false,
  node_whitelist: (cond do
    Mix.env() == :test -> [~r/^.*$/]
    true -> [~r/^pigeon.*$/]
  end)

config :peerage, debug: false, interval: 1
ips = System.get_env("NODE_IPS")
cond do
  Mix.env() == :test -> config :peerage, via: Peerage.Via.Self
  ips == nil -> config :peerage, via: Peerage.Via.Udp, serves: true
  true ->
    config :peerage, via: Peerage.Via.List, node_list: String.split(ips)
      |> Enum.map(&String.to_atom("pigeon@"<>&1))
end
