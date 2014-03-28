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

      iex> FunnelCli.CLI.parse_args(["query", "twitter", "body"])
      {:query, "twitter", "body", "funnel"}

      iex> FunnelCli.CLI.parse_args(["query", "twitter", "body", "-name", "chatgris"])
      {:query, "twitter", "body", "chatgris"}

      iex> FunnelCli.CLI.parse_args(["queries", "twitter"])
      {:queries, "twitter", "funnel"}

      iex> FunnelCli.CLI.parse_args(["queries", "twitter", "-name", "chatgris"])
      {:queries, "twitter", "chatgris"}

      iex> FunnelCli.CLI.parse_args(["listen"])
      {:listen}

      iex> FunnelCli.CLI.parse_args(["push", "twitter", "body"])
      {:push, "twitter", "body", "funnel"}

      iex> FunnelCli.CLI.parse_args(["push", "twitter", "body", "-name", "name"])
      {:push, "twitter", "body", "name"}
  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean],
                                     aliases:  [h: :help, n: :name]
    )
    case parse do
      {options, ["register", host], _}             -> {:register, host, options[:name] || "funnel"}
      {options, ["index", index_name, body], _}    -> {:index, index_name, body, options[:name] || "funnel"}
      {options, ["queries", index_name], _}        -> {:queries, index_name, options[:name] || "funnel"}
      {options, ["query", index_name, body], _}    -> {:query, index_name, body, options[:name] || "funnel"}
      {_options, ["listen"], _}                    -> {:listen}
      {options, ["push", index_name, body], _}     -> {:push, index_name, body, options[:name] || "funnel"}
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
      |> log_out(:register)
  end

  defp process({:index, index_name, body, name}) do
    configuration = Configuration.read(name)
    FunnelCli.Client.index(body, configuration["connection"])
      |> write_index(configuration, index_name)
      |> log_out(:index)
  end

  defp log_out(path, :register) do
    "%{green}File written to #{path}"
      |> IO.ANSI.escape(true)
      |> IO.puts
  end

  defp log_out(index, :index) do
    "%{green}#{index[:name]} registered as #{index[:id]}"
      |> IO.ANSI.escape(true)
      |> IO.puts
  end

  defp write_index(response, configuration, index_name) do
    [name: index_name, id: response["index_id"]]
      |> Configuration.add_index(configuration)
  end
end
