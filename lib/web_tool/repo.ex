defmodule WebTool.Repo do
  use Ecto.Repo,
    otp_app: :web_tool,
    adapter: Ecto.Adapters.Postgres
end
