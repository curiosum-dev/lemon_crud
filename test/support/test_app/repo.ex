defmodule LemonCrud.TestApp.Repo do
  use Ecto.Repo,
    otp_app: :lemon_crud,
    adapter: Ecto.Adapters.Postgres
end
