defmodule LemonCrud.GetTest do
  use LemonCrud.DataCase
  doctest LemonCrud

  alias LemonCrud.TestApp.{Category, Item, Subcategory}
  alias LemonCrud.TestApp.Contexts.ItemContext

  import LemonCrud.TestRecords

  setup [:test_records]

  describe "get/1" do
    test "returns the resource", %{items: [%{id: id} | _]} do
      assert %Item{id: ^id} = ItemContext.get_item(id)
    end

    test "returns the resource with subcategory preload", %{
      items: [%{id: id, subcategory_id: subcategory_id} | _]
    } do
      assert %Item{id: ^id, subcategory: %Subcategory{id: ^subcategory_id}} =
               ItemContext.get_item(id, :subcategory)
    end

    test "returns the resource with subcategory and category preloads", %{
      items: [%{id: id, subcategory_id: subcategory_id} | _],
      subcategories: subcategories
    } do
      category_id =
        subcategories |> Enum.find(&(&1.id == subcategory_id)) |> Map.get(:category_id)

      assert %Item{
               id: ^id,
               subcategory: %Subcategory{
                 id: ^subcategory_id,
                 category: %Category{id: ^category_id}
               }
             } =
               ItemContext.get_item(id, subcategory: :category)
    end

    test "returns nil if the resource does not exist" do
      assert nil == ItemContext.get_item(0)
    end
  end
end
