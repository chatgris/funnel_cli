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

  def index(body, connection) do
    HTTPotion.post("#{connection["host"]}/index", body, headers_with_auth(connection))
      |> get_body
      |> process_response_body
  end

  def query(body, index_id, connection) do
    HTTPotion.post("#{connection["host"]}/index/#{index_id}", body, headers_with_auth(connection))
      |> get_body
      |> process_response_body
  end

  def queries(index_id, connection) do
    HTTPotion.get("#{connection["host"]}/index/#{index_id}/queries", headers_with_auth(connection))
      |> get_body
      |> process_response_body
  end

  def push(index_id, body, connection) do
    HTTPotion.post("#{connection["host"]}/index/#{index_id}/feeding", body, headers_with_auth(connection))
      |> get_body
  end

  defp get_body(response) do
    response.body
  end

  defp headers_with_auth(connection) do
    Dict.put process_request_headers, "Authorization", connection["token"]
  end
end
