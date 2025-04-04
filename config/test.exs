import Config

config :lemon_crud, ecto_repos: [LemonCrud.TestApp.Repo]

config :lemon_crud, LemonCrud.TestApp.Repo,
  database: "lemon_crud_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  log: false
