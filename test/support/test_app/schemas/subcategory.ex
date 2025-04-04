defmodule LemonCrud.TestApp.Subcategory do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Schema

  schema "subcategories" do
    field(:name, :string)
    belongs_to(:category, LemonCrud.TestApp.Category)
    has_many(:items, LemonCrud.TestApp.Item)
    timestamps()
  end

  def changeset(subcategory, attrs) do
    subcategory
    |> cast(attrs, [:name, :category_id])
    |> validate_required([:name, :category_id])
    |> assoc_constraint(:category)
    |> unique_constraint([:category_id, :name])
  end
end
