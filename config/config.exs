import Config
config :nanoid, size: 7
config :pigeon, cluster: Swarm, replicas: 3

config :swarm, distribution_strategy: Swarm.Distribution,
  debug: false, node_whitelist: [~r/^pigeon@.*$/]

config :peerage, interval: 1
ips = System.get_env("NODE_IPS")
if ips == nil do
  config :peerage, via: Peerage.Via.Udp, serves: true
else
  config :peerage, via: Peerage.Via.List, node_list: String.split(ips)
    |> Enum.map(&String.to_atom("pigeon@"<>&1))
end

config :logger, backends: [{FlexLogger, :flexlog}], flexlog: [
  logger: :console,
  default_level: :debug,
  level_config: [
    [module: Foo, level: :info],
    [application: :peerage, level: :off],
    [application: :horde, level: :off],
    [application: :swarm, level: :off],
  ]]
