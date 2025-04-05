defmodule LemonCrud.TestApp.Category do
  @moduledoc false
  use Ecto.Schema
  # use LemonCrud.Schema.CounterFields
  import Ecto.Changeset
  import Ecto.Schema

  schema "categories" do
    field(:name, :string)
    has_many(:subcategories, LemonCrud.TestApp.Subcategory)
    has_many(:items, through: [:subcategories, :items])

    field(:subcategories_count, :integer, virtual: true, default: nil)
    field(:items_count, :integer, virtual: true, default: nil)

    timestamps()
  end

  def __counter_fields__, do: [:subcategories, :items]

  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
