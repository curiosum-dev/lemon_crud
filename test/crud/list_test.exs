defmodule LemonCrud.ListTest do
  use LemonCrud.DataCase
  doctest LemonCrud

  alias LemonCrud.TestApp.Item
  alias LemonCrud.TestApp.Contexts.{CategoryContext, ItemContext, SubcategoryContext}

  import LemonCrud.TestRecords
  import Ecto.Query

  setup [:test_records]

  describe "list_*/0" do
    test "list_categories/0", %{categories: categories} do
      assert CategoryContext.list_categories() |> MapSet.new() == categories |> MapSet.new()
    end

    test "list_subcategories/0", %{subcategories: subcategories} do
      assert SubcategoryContext.list_subcategories() |> MapSet.new() ==
               subcategories |> MapSet.new()
    end

    test "list_items/0", %{items: items} do
      assert ItemContext.list_items() |> MapSet.new() == items |> MapSet.new()
    end
  end

  describe "list_*/1" do
    test "list_items(Item)", %{items: items} do
      assert ItemContext.list_items(Item) |> MapSet.new() == items |> MapSet.new()
    end

    test "list_items(Item, limit: 2, offset: 1, order_by: [desc: :name])" do
      assert ItemContext.list_items(Item, limit: 2, offset: 1, order_by: [desc: :name])
             |> Enum.map(& &1.name) ==
               [
                 "Item 2.2.1",
                 "Item 2.1.2"
               ]
    end

    test "list_items(Ecto.Query.t())", %{items: items} do
      assert ItemContext.list_items(from(i in Item, where: like(i.name, "Item 1.2.%")))
             |> MapSet.new() ==
               items
               |> Enum.filter(&String.starts_with?(&1.name, "Item 1.2."))
               |> MapSet.new()
    end

    test ~s{list_items(subcategory: [name: "Subcategory 1.1"])}, %{items: items} do
      loaded_items = ItemContext.list_items(subcategory: [name: "Subcategory 1.1"])

      assert loaded_items |> length ==
               items |> Enum.count(&String.starts_with?(&1.name, "Item 1.1."))

      assert loaded_items
             |> Enum.all?(fn item -> String.starts_with?(item.name, "Item 1.1.") end)
    end

    test ~s{list_items(subcategory: [category: [name: "Category 1"]])}, %{items: items} do
      loaded_items =
        ItemContext.list_items(subcategory: [category: [name: "Category 2"]])

      assert loaded_items |> length ==
               items |> Enum.count(&String.starts_with?(&1.name, "Item 2."))

      assert loaded_items
             |> Enum.all?(fn item -> String.starts_with?(item.name, "Item 2.") end)
    end

    test "list_items(subcategory_id: 1, preload: [subcategory: :category], limit: 1, offset: 1, order_by: [desc: :name])",
         %{
           subcategories: [subcategory1 | _]
         } do
      loaded_items =
        ItemContext.list_items(
          subcategory_id: subcategory1.id,
          preload: [subcategory: :category],
          limit: 1,
          offset: 1,
          order_by: [desc: :name]
        )

      assert loaded_items |> length == 1

      assert loaded_items
             |> Enum.all?(fn item -> String.starts_with?(item.name, "Item 1.1.") end)

      assert loaded_items
             |> Enum.all?(fn item -> item.subcategory.category.name == "Category 1" end)
    end
  end

  describe "list_*/2" do
    test "list_items(Ecto.Query.t(), preload: :subcategory)", %{items: items} do
      loaded_items =
        ItemContext.list_items(
          from(i in Item, where: like(i.name, "Item 1.2.%"), preload: :subcategory)
        )

      assert loaded_items |> length ==
               items |> Enum.count(&String.starts_with?(&1.name, "Item 1.2."))

      assert loaded_items
             |> Enum.map(& &1.name)
             |> Enum.all?(fn name -> String.starts_with?(name, "Item 1.2.") end)

      assert loaded_items |> Enum.all?(fn item -> item.subcategory.name == "Subcategory 1.2" end)
    end

    test "list_items(Ecto.Query.t(), preload: :subcategory, limit: 1, offset: 1, order_by: [desc: :name])" do
      loaded_items =
        ItemContext.list_items(
          from(i in Item,
            where: like(i.name, "Item 1.2.%"),
            preload: :subcategory,
            limit: 1,
            offset: 1,
            order_by: [desc: :name]
          )
        )

      assert loaded_items |> length == 1

      assert loaded_items
             |> Enum.map(& &1.name)
             |> Enum.all?(fn name -> String.starts_with?(name, "Item 1.2.") end)

      assert loaded_items |> Enum.all?(fn item -> item.subcategory.name == "Subcategory 1.2" end)
    end

    test "list_items(Ecto.Query.t(), preload: [:subcategory])", %{items: items} do
      loaded_items =
        ItemContext.list_items(
          from(i in Item, where: like(i.name, "Item 1.2.%"), preload: [:subcategory])
        )

      assert loaded_items |> length ==
               items |> Enum.count(&String.starts_with?(&1.name, "Item 1.2."))

      assert loaded_items
             |> Enum.all?(fn item -> String.starts_with?(item.name, "Item 1.2.") end)

      assert loaded_items
             |> Enum.all?(fn item -> item.subcategory.name == "Subcategory 1.2" end)
    end

    test "list_items(Ecto.Query.t(), preload: [subcategory: :category])", %{items: items} do
      loaded_items =
        ItemContext.list_items(
          from(i in Item, where: like(i.name, "Item 1.2.%"), preload: [subcategory: :category])
        )

      assert loaded_items |> length ==
               items |> Enum.count(&String.starts_with?(&1.name, "Item 1.2."))

      assert loaded_items
             |> Enum.all?(fn item -> String.starts_with?(item.name, "Item 1.2.") end)

      assert loaded_items
             |> Enum.all?(fn item -> item.subcategory.name == "Subcategory 1.2" end)

      assert loaded_items
             |> Enum.all?(fn item -> item.subcategory.category.name == "Category 1" end)
    end

    test "list_items(Ecto.Query.t(), preload: [subcategory: [:category]])", %{items: items} do
      loaded_items =
        ItemContext.list_items(
          from(i in Item, where: like(i.name, "Item 1.2.%"), preload: [subcategory: :category])
        )

      assert loaded_items |> length ==
               items |> Enum.count(&String.starts_with?(&1.name, "Item 1.2."))

      assert loaded_items
             |> Enum.all?(fn item -> String.starts_with?(item.name, "Item 1.2.") end)

      assert loaded_items
             |> Enum.all?(fn item -> item.subcategory.name == "Subcategory 1.2" end)

      assert loaded_items
             |> Enum.all?(fn item -> item.subcategory.category.name == "Category 1" end)
    end
  end
end
