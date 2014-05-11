defmodule FunnelCli.Mixfile do
  use Mix.Project

  def project do
    [ app: :funnel_cli,
      version: "0.0.1",
      elixir: "~> 0.13",
      escript_main_module: FunnelCli,
      escript_embed_elixir: true,
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [ applications: [:httpotion]]
  end

  defp deps do
    [
      { :httpotion,   github: "myfreeweb/httpotion" },
      { :jsex,        '~> 2.0' }
    ]
  end
end
