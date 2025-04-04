defmodule LemonCrud.TestApp.Contexts.SubcategoryContext do
  @moduledoc false
  use LemonCrud,
    repo: LemonCrud.TestApp.Repo,
    schema: LemonCrud.TestApp.Subcategory,
    plural_resource_name: "subcategories"
end
