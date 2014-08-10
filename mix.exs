defmodule FunnelCli.Mixfile do
  use Mix.Project

  def project do
    [ app: :funnel_cli,
      version: "0.0.1",
      elixir: "~> 0.15",
      escript_main_module: FunnelCli,
      escript_embed_elixir: true,
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [ applications: [:httpoison, :jsex, :funnel]]
  end

  defp deps do
    [
      {:funnel,               "~> 0.1"},
      {:hackney,   github: "benoitc/hackney", tag: "0.13.0" },
      {:jsex,      "~> 2.0" }
    ]
  end
end
