ExUnit.start()

{:ok, _} = Ecto.Adapters.Postgres.ensure_all_started(LemonCrud.TestApp.Repo, :temporary)
{:ok, _pid} = LemonCrud.TestApp.Repo.start_link()

Process.flag(:trap_exit, true)
