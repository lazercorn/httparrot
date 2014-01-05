defmodule HTTParrot.BasicAuthHandler do
  @moduledoc """
  Challenges HTTPBasic Auth
  """
  def init(_transport, _req, _opts) do
    {:upgrade, :protocol, :cowboy_rest}
  end

  def allowed_methods(req, state) do
    {["GET"], req, state}
  end

  def is_authorized(req, state) do
    {user, req} = :cowboy_req.binding(:user, req)
    {passwd, req} = :cowboy_req.binding(:passwd, req)
    {:ok, auth, req} = :cowboy_req.parse_header("authorization", req)
    case auth do
      {"basic", {^user, ^passwd}} -> {true, req, user}
      _ -> {{false, "Basic realm=\"Fake Realm\""}, req, state}
    end
  end

  def content_types_provided(req, state) do
    {[{{"application", "json", []}, :get_json}], req, state}
  end

  def get_json(req, user) do
    {response(user), req, nil}
  end

  defp response(user) do
    [authenticated: true, user: user] |> JSEX.encode!
  end

  def terminate(_, _, _), do: :ok
end
