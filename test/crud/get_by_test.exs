defmodule LemonCrud.GetByTest do
  use LemonCrud.DataCase
  doctest LemonCrud

  alias LemonCrud.TestApp.{Category, Item, Subcategory}
  alias LemonCrud.TestApp.Contexts.ItemContext

  import LemonCrud.TestRecords
  import Ecto.Query
  setup [:test_records]

  describe "get_*_by/1" do
    test ~s{get_item_by(name: "Item 1.1.1")}, %{items: items} do
      assert ItemContext.get_item_by(name: "Item 1.1.1") ==
               items |> Enum.find(&(&1.name == "Item 1.1.1"))
    end

    test ~s{get_item_by(name: "Item 1.1.1", preload: :subcategory)} do
      assert %Item{subcategory: %Subcategory{name: "Subcategory 1.1"}} =
               ItemContext.get_item_by(name: "Item 1.1.1", preload: :subcategory)
    end

    test ~s{get_item_by(name: "Item 1.1.1", preload: [subcategory: :category])} do
      assert %Item{
               subcategory: %Subcategory{
                 name: "Subcategory 1.1",
                 category: %Category{name: "Category 1"}
               }
             } =
               ItemContext.get_item_by(name: "Item 1.1.1", preload: [subcategory: :category])
    end

    test ~s{get_item_by(from(i in Item, where: like(i.name, "Item 1.1.%") and i.serial_number == "1234567890"))} do
      assert %Item{name: "Item 1.1.1"} =
               ItemContext.get_item_by(
                 from(i in Item,
                   where: like(i.name, "Item 1.1.%") and i.serial_number == "1234567890"
                 )
               )
    end

    test ~s{get_item_by(from(i in Item, where: i.serial_number == "nonexistent"))} do
      assert nil ==
               ItemContext.get_item_by(from(i in Item, where: i.serial_number == "nonexistent"))
    end

    test "get_item_by with empty conditions raises Ecto.MultipleResultsError" do
      assert_raise Ecto.MultipleResultsError, fn ->
        ItemContext.get_item_by(%{})
      end
    end

    test "get_item_by with non-unique condition raises Ecto.MultipleResultsError", %{
      subcategories: [subcategory1 | _]
    } do
      assert_raise Ecto.MultipleResultsError, fn ->
        ItemContext.get_item_by(subcategory_id: subcategory1.id)
      end
    end

    test "get_item_by with high offset returns nil" do
      assert nil == ItemContext.get_item_by(name: "Item 1.1.1", offset: 100)
    end

    test "get_item_by with unknown field raises an error" do
      assert_raise Ecto.QueryError, fn ->
        ItemContext.get_item_by(foo: "bar")
      end
    end
  end

  describe("get_*_by!/1") do
    test ~s{get_item_by!(name: "Item 1.1.1")}, %{items: items} do
      assert ItemContext.get_item_by!(name: "Item 1.1.1") ==
               items |> Enum.find(&(&1.name == "Item 1.1.1"))
    end

    test ~s{get_item_by!(name: "Item 1.1.1", preload: :subcategory)} do
      assert %Item{subcategory: %Subcategory{name: "Subcategory 1.1"}} =
               ItemContext.get_item_by!(name: "Item 1.1.1", preload: :subcategory)
    end

    test ~s{get_item_by!(name: "Item 1.1.1", preload: [subcategory: :category])} do
      assert %Item{
               subcategory: %Subcategory{
                 name: "Subcategory 1.1",
                 category: %Category{name: "Category 1"}
               }
             } =
               ItemContext.get_item_by!(name: "Item 1.1.1", preload: [subcategory: :category])
    end

    test ~s{get_item_by!(from(i in Item, where: like(i.name, "Item 1.1.%") and i.serial_number == "1234567890"))} do
      assert %Item{name: "Item 1.1.1"} =
               ItemContext.get_item_by!(
                 from(i in Item,
                   where: like(i.name, "Item 1.1.%") and i.serial_number == "1234567890"
                 )
               )
    end

    test "get_item_by!(from(i in Item, where: i.serial_number == \"nonexistent\"))" do
      assert_raise Ecto.NoResultsError, fn ->
        ItemContext.get_item_by!(from(i in Item, where: i.serial_number == "nonexistent"))
      end
    end

    test "get_item_by! with empty conditions raises Ecto.MultipleResultsError" do
      assert_raise Ecto.MultipleResultsError, fn ->
        ItemContext.get_item_by!(%{})
      end
    end

    test "get_item_by! with high offset raises Ecto.NoResultsError" do
      assert_raise Ecto.NoResultsError, fn ->
        ItemContext.get_item_by!(name: "Item 1.1.1", offset: 1)
      end
    end
  end

  describe("get_*_by/2") do
    test ~s{get_item_by(from(i in Item, where: like(i.name, "Item 1.1.%") and i.serial_number == "1234567890"), preload: [subcategory: :category])} do
      assert %Item{
               name: "Item 1.1.1",
               subcategory: %Subcategory{
                 name: "Subcategory 1.1",
                 category: %Category{name: "Category 1"}
               }
             } =
               ItemContext.get_item_by(
                 from(i in Item,
                   where: like(i.name, "Item 1.1.%") and i.serial_number == "1234567890"
                 ),
                 preload: [subcategory: :category]
               )
    end
  end

  describe("get_*_by!/2") do
    test ~s{get_item_by!(from(i in Item, where: like(i.name, "Item 1.1.%") and i.serial_number == "1234567890"), preload: [subcategory: :category])} do
      assert %Item{
               name: "Item 1.1.1",
               subcategory: %Subcategory{
                 name: "Subcategory 1.1",
                 category: %Category{name: "Category 1"}
               }
             } =
               ItemContext.get_item_by!(
                 from(i in Item,
                   where: like(i.name, "Item 1.1.%") and i.serial_number == "1234567890"
                 ),
                 preload: [subcategory: :category]
               )
    end
  end

  test "get_item_by with order, limit, and offset", %{subcategories: [subcategory1 | _]} do
    item =
      ItemContext.get_item_by(
        subcategory_id: subcategory1.id,
        order_by: [desc: :name],
        limit: 1,
        offset: 1
      )

    assert item.name == "Item 1.1.1"
  end

  test "get_item_by! with order, limit, and offset", %{subcategories: [subcategory1 | _]} do
    item =
      ItemContext.get_item_by!(
        subcategory_id: subcategory1.id,
        order_by: [desc: :name],
        limit: 1,
        offset: 1
      )

    assert item.name == "Item 1.1.1"
  end
end
