defmodule FunnelCli.CLI do
  @moduledoc """
  Command line interface to `FunnelCli
  """

  alias FunnelCli.Configuration

  @doc """
  FunnelCli.CLI main entry point
  """
  def run(argv) do
    argv
      |> parse_args
      |> process
  end

  @doc """
  `argv` can be -h or --help, which returns :help.

  ## Examples

      iex> FunnelCli.CLI.parse_args(["-h"])
      :help

      iex> FunnelCli.CLI.parse_args(["-help"])
      :help

      iex> FunnelCli.CLI.parse_args(["register", "http://localhost:4000"])
      {:register, "http://localhost:4000", "funnel"}

      iex> FunnelCli.CLI.parse_args(["register", "http://localhost:4000", "-n", "chatgris"])
      {:register, "http://localhost:4000", "chatgris"}

      iex> FunnelCli.CLI.parse_args(["register", "http://localhost:4000", "-name", "chatgris"])
      {:register, "http://localhost:4000", "chatgris"}

      iex> FunnelCli.CLI.parse_args(["index", "twitter", "body"])
      {:index, "twitter", "body", "funnel"}

      iex> FunnelCli.CLI.parse_args(["index", "twitter", "body", "-name", "chatgris"])
      {:index, "twitter", "body", "chatgris"}

  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean],
                                     aliases:  [h: :help, n: :name]
    )
    case parse do
      {options, ["register", host], _}             -> {:register, host, options[:name] || "funnel"}
      {options, ["index", index_name, body], _}    -> {:index, index_name, body, options[:name] || "funnel"}
      _                                            -> :help
    end
  end

  defp process(:help) do
    IO.puts """
    Welcome to FunnelCli \o/

    Usage:

    funnel_cli register http://funnel.dev
    funnel_cli index twitter index_configuration_in_json
    """
    System.halt(0)
  end

  defp process({:register, host, name}) do
    FunnelCli.Client.register(host)
      |> Configuration.write(host, name)
      |> log_out
  end

  defp process({:index, index_name, body, name}), do: IO.puts "Noop"

  defp log_out(path) do
    "%{green}File written to #{path}"
      |> IO.ANSI.escape(true)
      |> IO.puts
  end
end
