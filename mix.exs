defmodule Pigeon.MixProject do
  use Mix.Project
  def application do
    [mod: {Pigeon.Application, []},
    extra_applications: [:logger, :peerage]]
  end
  def project do
    [app: :pigeon,
    version: "0.1.0",
    elixir: "~> 1.10",
    elixirc_paths:
      if Mix.env() == :prod
      do ["lib", "cli"]
      else ["lib"] end,
    build_embedded: Mix.env() == :prod,
    start_permanent: Mix.env() == :prod,
    deps: [
      {:assert_eventually, "~> 0.2.2", only: :test},
      {:local_cluster, "~> 1.2.1", only: :test},
      {:schism, "~> 1.0.1", only: :test},
      {:flex_logger, "~> 0.2.1"},
      {:peerage, "~> 1.0.3"},
      {:swarm, "~> 3.4.0"},
      {:delta_crdt, "~> 0.5.10"},
      {:nanoid, "~> 2.0.4"},
      {:ratatouille, "~> 0.5.1", only: :prod},
    ]]
  end
end
