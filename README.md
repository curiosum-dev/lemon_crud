# LemonCrud

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

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## Further reading

Full documentation can be found at <https://hexdocs.pm/lemon_crud>.

## License

[Curiosum](https://curiosum.com)

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.

