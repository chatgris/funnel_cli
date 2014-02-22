defmodule FunnelCli.Mixfile do
  use Mix.Project

  def project do
    [ app: :funnel_cli,
      version: "0.0.1",
      elixir: "~> 0.12.4",
      escript_main_module: FunnelCli,
      escript_embed_elixir: true,
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [mod: { FunnelCli, [] }]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat" }
  defp deps do
    []
  end
end
