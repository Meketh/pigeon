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
    build_embedded: Mix.env() == :prod,
    start_permanent: Mix.env() == :prod,
    aliases: [
      test: "test --no-start",
      run: "run --no-halt",
    ],
    deps: [
      {:local_cluster, "~> 1.2.1", only: [:test]},
      {:schism, "~> 1.0.1", only: [:test]},
      {:flex_logger, "~> 0.2.1"},
      {:ratatouille, "~> 0.5.1"},
      {:peerage, "~> 1.0.3"},
      {:swarm, "~> 3.4.0"},
      {:nanoid, "~> 2.0.4"},
    ]]
  end
end
