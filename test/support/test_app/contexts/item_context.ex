defmodule LemonCrud.TestApp.Contexts.ItemContext do
  @moduledoc false
  use LemonCrud,
    repo: LemonCrud.TestApp.Repo,
    schema: LemonCrud.TestApp.Item,
    plural_resource_name: "items"
end
