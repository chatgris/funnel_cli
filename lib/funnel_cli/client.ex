defmodule FunnelCli.Client do
  use HTTPotion.Base

  def process_request_headers(headers \\ HashDict.new) do
    headers = Dict.put headers, "User-Agent", "funnel_cli"
    headers = Dict.put headers, "Content-Type", "application/json"
    Dict.put headers, "Accept", "application/json"
  end

  def process_response_body(body) do
    {:ok, body} = JSEX.decode(body)
    body
  end

  def register(host) do
    HTTPotion.post("#{host}/register", "")
      |> get_body
      |> process_response_body
  end

  defp get_body(response) do
    response.body
  end
end
