defmodule FunnelCli.Configuration do
  @moduledoc """
  Handle write/read of Configuration
  """

  @doc """
  Write configuration to a file.
  """
  def write(response, host, name \\ "funnel") do
    response
      |> configure(name, host)
      |> serialize
      |> write_to_fs(name)
  end

  @doc """
  Read configuration from a file.
  """
  def read(name \\ "funnel") do
    configuration_path(name)
      |> File.read
      |> unserialize
  end

  def add_index(index, configuration) do
    indexes = configuration[:indexes] || []
    Dict.put(configuration, :indexes, [index | indexes])
      |> serialize
      |> write_to_fs(configuration["connection"]["name"])
    index
  end

  def find_index(name, configuration) do
    Enum.find(configuration["indexes"], fn(index) -> index["name"] == name end)
  end

  defp configuration_path(name) do
    "#{Path.expand("~")}/.funnel_#{name}_configuration.json"
  end

  defp unserialize({:ok, body}) do
    {:ok, body} = JSEX.decode(body)
    body
  end

  defp unserialize({:error, reason}) do
    "%{red}[Error] #{reason}"
      |> IO.ANSI.escape(true)
      |> IO.puts
    System.halt(1)
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
    File.write(path, body)
    path
  end
end
