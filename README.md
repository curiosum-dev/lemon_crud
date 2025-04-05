# LemonCrud

[![Hex.pm](https://img.shields.io/hexpm/v/lemon_crud.svg)](https://hex.pm/packages/lemon_crud)
[![CI](https://github.com/curiosum-dev/lemon_crud/actions/workflows/ci.yml/badge.svg)](https://github.com/curiosum-dev/lemon_crud/actions/workflows/ci.yml)
[![Coverage Status](https://codecov.io/gh/curiosum-dev/lemon_crud/branch/main/graph/badge.svg)](https://codecov.io/gh/curiosum-dev/lemon_crud)
[![License](https://img.shields.io/hexpm/l/lemon_crud.svg)](https://github.com/curiosum-dev/lemon_crud/blob/main/LICENSE)

LemonCrud is a small library creating uniform yet flexible CRUD functions for your Phoenix contexts to reduce generated boilerplate.

Paired with [Contexted](https://github.com/curiosum-dev/contexted), it adds a productivity benefit on top of Contexted's help in organizing Phoenix contexts in a nice and tidy way.

## Installation

The package can be installed
by adding `lemon_crud` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:lemon_crud, "~> 0.1.0"}
  ]
end
```

## Usage

In most web apps CRUD operations are very common. Most of these, have the same pattern. Most of the time, they are used with preloading associated resources as well as filtering based on conditions such as search, pagination, etc.

Why not autogenerate them?

Here is how you can generate common CRUD operations for `App.Account.Users`:

```elixir
defmodule App.Account.Users do
  use LemonCrud,
    repo: App.Repo,
    schema: App.Accounts.User
end
```

This will generate the following functions:

```elixir
iex> App.Accounts.Users.__info__(:functions)
[
  change_user: 1,
  change_user: 2,
  create_user: 0,
  create_user: 1,
  create_user!: 0,
  create_user!: 1,
  delete_user: 1,
  delete_user!: 1,
  get_user: 1,
  get_user!: 1,
  get_user_by: 1,
  get_user_by!: 1,
  get_user_by: 2,
  get_user_by!: 2,
  list_users: 0,
  list_users: 1,
  list_users: 2,
  update_user: 1,
  update_user: 2,
  update_user!: 1,
  update_user!: 2
]
```

Generated creation and updating functions default to the corresponding schema's `changeset/1` and `changeset/2` functions, respectively, whereas list and get functions provide a means to manipulate the result by:

* filtering conditions (via plain exact match condition lists or by passing an Ecto.Query)
* preloads
* orderings
* limits
* offsets

Examples:

```elixir
# List all users with posts preloaded
iex> App.Accounts.Users.list_users(preload: [:posts])

# Use an Ecto.Query to filter users, and a keyword list of options to manipulate the result
iex> App.Accounts.Users.list_users(
  App.Accounts.User |> where([u], u.status == "active"),
  preload: [:posts],
  order_by: [desc: :inserted_at],
  limit: 10,
  offset: 0
)

# Use a keyword list of exact match conditions and manipulation options
iex> App.Accounts.Users.list_users(
  status: "active",
  subscription: [plan: "free"],
  order_by: [desc: :inserted_at]
)

# Get a user by ID with subscription preloaded
iex> App.Accounts.Users.get_user!(10, preload: [:subscription])

# Get a user by profile email with profile and subscription preloaded
iex> App.Accounts.Users.get_user_by!(profile: [email: "user@example.com"], preload: [:profile, :subscription])

# Use an Ecto.Query to get a specific user
iex> App.Accounts.Users.get_user_by!(App.Accounts.User |> where([u], u.id == 10), preload: [:profile, :subscription])
```

## Using Ecto Queries

LemonCrud provides built-in support for using Ecto queries directly as arguments to the generated functions. This gives you more flexibility and power when you need more complex filtering than what the simple keyword list conditions can provide.

### List Functions with Ecto Queries

You can pass an Ecto query as the first argument to any `list_*` function:

```elixir
# Basic query with a WHERE clause
iex> ItemContext.list_items(from(i in Item, where: like(i.name, "Item 1.2.%")))

# Combining a query with additional options.
#
# Note that the second dargument can still take options as described earlier -
# they will be appended to the base queryable provided in the first argument.
iex> ItemContext.list_items(
  from(i in Item, where: like(i.name, "Item 1.2.%")),
  limit: 1,
  offset: 1,
  order_by: [desc: :name]
)

# The schema module can also be used directly, as it's also a queryable.
iex> ItemContext.list_items(Item, limit: 2, offset: 1, order_by: [desc: :name])
```

### Get Functions with Ecto Queries

Similarly, the `get_*_by` and `get_*_by!` functions can accept Ecto queries - behaving in line with their underlying calls to `Ecto.Repo`'s `get_by` and `get_by!` functions, respectively:

```elixir
# Find a record with a complex WHERE condition
iex> ItemContext.get_item_by(
  from(i in Item,
    where: like(i.name, "Item 1.1.%") and i.serial_number == "1234567890"
  )
)

# Using a query with preloads
iex> CategoryContext.get_category_by(
  from(c in Category, where: c.id == ^category_id),
  preload: [:subcategories]
)
```

These query-based approaches are especially useful when:

1. You need complex filtering logic (multiple conditions, OR clauses, etc.)
2. You want to use SQL functions (like `like`, `in`, etc.)
3. You need to join with tables that aren't directly accessible via associations
4. You want to dynamically build queries based on user input

A pattern we use and recommend is keeping contexts clear of bloat from query-building code, which is delegated to specialized query modules - see [our article on query module pattern](https://curiosum.com/blog/composable-elixir-ecto-queries-modules).

## Query Options

When using plain keyword lists for filtering, in addition to `preload`, LemonCrud provides several options for manipulating the constructed Ecto query covering most common use cases: `limit` and `offset` for pagination purposes, and `order_by` for sorting.

Another option is `count` that joins the base query with subqueries counting related records in a specific association.

It should be noted that, when more advanced query manipulations are needed, pre-constructed Ecto queries should be used instead of keyword lists in the arguments of the functions.

### limit

The `limit` option restricts the number of results returned by the query. Under the hood, it applies `Ecto.Query.limit/2` to your query.

```elixir
# Get only the first item sorted by name in descending order
iex> ItemContext.list_items(limit: 1, order_by: [desc: :name])

# Apply limit combined with other options
iex> ItemContext.list_items(
  subcategory_id: subcategory.id,
  preload: [subcategory: :category],
  limit: 1,
  offset: 1,
  order_by: [desc: :name]
)
```

### offset

The `offset` option skips a specific number of results before returning the rest. This is commonly used with `limit` for pagination. Under the hood, it applies `Ecto.Query.offset/2` to your query.

```elixir
# Skip the first item and get the next two, sorted by name in descending order
iex> ItemContext.list_items(limit: 2, offset: 1, order_by: [desc: :name])

# Can be used with Ecto.Query as well
iex> ItemContext.list_items(
  from(i in Item, where: like(i.name, "Item 1.2.%")),
  limit: 1,
  offset: 1,
  order_by: [desc: :name]
)
```

### order_by

The `order_by` option sorts the results based on specified fields and directions. Under the hood, it applies `Ecto.Query.order_by/3` to your query.

```elixir
# Sort items by name in descending order
iex> ItemContext.list_items(order_by: [desc: :name])

# Can be used with filtering conditions
iex> CategoryContext.list_categories(
  count: [:subcategories, :items],
  order_by: [desc: :id]
)
```

### count

The `count` option adds virtual fields to your results with counts of associated records. Under the hood, it adds left-joined subqueries to count the associations and adds the counts as values virtual fields named `[association_name]_count`.

These virtual fields need to be defined in the schema, preferably defaulting to nil.

```elixir
# Count associations for all categories
iex> CategoryContext.list_categories(count: [:subcategories, :items])
# Result example:
# [
#   %Category{id: 1, name: "Category 1", subcategories_count: 2, items_count: 4},
#   %Category{id: 2, name: "Category 2", subcategories_count: 2, items_count: 4}
# ]

# Can be combined with other options
iex> CategoryContext.list_categories(
  id: category.id,
  count: [:subcategories, :items],
  order_by: [desc: :id]
)

# Works with get_by as well
iex> CategoryContext.get_category_by(
  name: "Category 1",
  count: [:subcategories, :items],
  preload: [:subcategories]
)
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## Further reading

Full documentation can be found at <https://hexdocs.pm/lemon_crud>.

## License

[Curiosum](https://curiosum.com)

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.

