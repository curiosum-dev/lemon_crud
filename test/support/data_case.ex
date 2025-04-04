defmodule LemonCrud.DataCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox
  alias LemonCrud.TestApp.Repo

  using do
    quote do
      alias LemonCrud.TestApp.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import LemonCrud.DataCase
      import LemonCrud.TestRecords, only: [test_records: 1]
    end
  end

  setup tags do
    :ok = Sandbox.checkout(Repo)

    unless tags[:async] do
      Sandbox.mode(Repo, {:shared, self()})
    end

    :ok
  end
end
