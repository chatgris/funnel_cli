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
    parse = OptionParser.parse(argv, aliases: [h: :help, n: :name])

    case parse do
      {options, ["register", host], switches}             -> {:register, host, options[:name] || switches[:name] || "funnel"}
      {options, ["index", index_name, body], switches}    -> {:index, index_name, body, options[:name] || switches[:name] || "funnel"}
      {options, ["queries", index_name], switches}        -> {:queries, index_name, options[:name] || switches[:name] || "funnel"}
      {options, ["query", index_name, body], switches}    -> {:query, index_name, body, options[:name] || switches[:name] || "funnel"}
      {_options, ["listen"], _switches}                   -> {:listen}
      {options, ["push", index_name, body], switches}     -> {:push, index_name, body, options[:name] || switches[:name] || "funnel"}
      _                                                   -> :help
    end
  end

  defp process(:help) do
    IO.puts """
    Welcome to FunnelCli \o/

    Usage:

      * funnel_cli register http://funnel.dev
      * funnel_cli index index_name index_configuration_in_json
      * funnel_cli query index_name query_configuration_in_json
      * funnel_cli queries index_name

    Option:

      * `-name`: Select a configuration name. Aliased as `-n`
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

  defp process({:query, index_name, body, name}) do
    configuration = Configuration.read(name)
    index = index_from_configuration(index_name, configuration)

    FunnelCli.Client.query(body, index["id"], configuration["connection"])
      |> log_out(:query, index_name)
  end

  defp process({:queries, index_name, name}) do
    configuration = Configuration.read(name)
    index = index_from_configuration(index_name, configuration)

    FunnelCli.Client.queries(index["id"], configuration["connection"])
      |> log_out(:queries, index_name)
  end

  defp log_out(path, :register) do
    "%{green}File written to #{path}"
      |> out
  end

  defp log_out(index, :index) do
    "%{green}#{index[:name]} registered as #{index[:id]}"
      |> out
  end

  defp log_out(message, :error) do
    "%{red}#{message}"
      |> out
    System.halt(1)
  end

  defp log_out(query, :query, index_name) do
    "%{green}New query added as #{query["query_id"]} to #{index_name} index."
  end

  defp log_out(queries, :queries, index_name) do
    "%{green}#{index_name} queries:"
      |> out
    Enum.each(queries, &log_out_query/1)
  end

  defp log_out_query(query) do
    "%{cyan}  * #{query["query_id"]}"
      |> out
  end

  defp write_index(response, configuration, index_name) do
    [name: index_name, id: response["index_id"]]
      |> Configuration.add_index(configuration)
  end

  defp out(message) do
    message
      |> IO.ANSI.escape(true)
      |> IO.puts
  end

  defp index_from_configuration(index_name, configuration) do
    case Configuration.find_index(index_name, configuration) do
      nil   -> log_out("No index found", :error)
      index -> index
    end
  end
end
