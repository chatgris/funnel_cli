defmodule FunnelCli.CLI do
  @moduledoc """
  Command line interface to `FunnelCli
  """

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

  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean],
                                     aliases:  [h: :help, n: :name]
    )
    case parse do
      {options, ["register", host], _}             -> {:register, host, options[:name] || "funnel"}
      _                                            -> :help
    end
  end

  defp process(:help) do
    IO.puts """
    Welcome to FunnelCli \o/

    Usage:

    funnel_cli register http://funnel.dev
    """
    System.halt(0)
  end

  defp process({:register, host, name}) do
    FunnelCli.Client.register(host)
      |> configure(name, host)
      |> serialize
      |> write_to_fs(name)
      |> log_out
  end

  defp configure(response, name, host) do
    configuration = HashDict.new
    connection    = HashDict.new
    connection = Dict.put(connection, :host, host)
    connection = Dict.put(connection, :token, response["token"])
    connection = Dict.put(connection, :name, name)
    Dict.put(configuration, :connection, connection)
  end

  defp serialize(configuration) do
    {:ok, body} = JSEX.encode(configuration)
    body
  end

  defp write_to_fs(body, name) do
    path = configuration_path(name)
    File.write!(path, body)
    path
  end

  defp log_out(path) do
    "%{green}File written to #{path}"
      |> IO.ANSI.escape(true)
      |> IO.puts
  end

  defp configuration_path(name) do
    "#{Path.expand("~")}/.funnel_#{name}_configuration.json"
  end
end
