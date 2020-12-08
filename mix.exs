defmodule Pigeon.MixProject do
  use Mix.Project
  def application, do: [
    mod: {Pigeon.Application, []},
    extra_applications: [:logger, :peerage]]
  def project, do: [
    app: :pigeon,
    version: "0.1.0",
    elixir: "~> 1.10",
    build_embedded: Mix.env() == :prod,
    start_permanent: Mix.env() == :prod,
    deps: [
      {:flex_logger, "~> 0.2.1"},
      {:peerage, "~> 1.0.3"},
      {:swarm, "~> 3.4.0"},
      {:horde, "~> 0.8.3"},
      {:delta_crdt, "~> 0.5.10"},
      {:uuid, "~> 1.1.8"},
    ]]
end
