defmodule LemonCrud.TestApp.Contexts.CategoryContext do
  @moduledoc false
  use LemonCrud,
    repo: LemonCrud.TestApp.Repo,
    schema: LemonCrud.TestApp.Category,
    plural_resource_name: "categories"
end
