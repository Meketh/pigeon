import Config
config :peerage, serves: true, interval: 1, via: Peerage.Via.Udp
config :logger, compile_time_purge_matching: [
  # [module: Bar, function: "foo/3", level_lower_than: :error],
  [application: :peerage],
  [application: :horde],
]
