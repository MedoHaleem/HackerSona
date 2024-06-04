defmodule HackerSona.Repo do
  use Ecto.Repo,
    otp_app: :hacker_sona,
    adapter: Ecto.Adapters.Postgres
end
