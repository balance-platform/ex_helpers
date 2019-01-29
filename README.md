# ExHelpers

Bunch of helper functions splitted in several separated modules.
With this lib you can:
- wrap up any stuff into list if content is not list itself (like `Array#wrap` in Ruby)
- parse any binary to date and define your own masks to it
- using dot-notation get and update complex map structure with given value
- and many more, please, refer to moduledocs 

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_helpers` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_helpers, "~> 0.1.0"}
  ]
end
```

## Using in apps

After installing lib as dependency you have several ways of use:

- You may just import single (or several) helper module, like: 
```elixir
defmodule Foo do
  # import full module
  import ExHelpers.Binary
  # or import single function for your special needs
  # import ExHelpers.Binary, only: [to_s: 1]
  
  def bar(val), do: ExHelpers.Binary.to_s(val)
end
Foo.bar(1) # => "1"
``` 

- Use single module (or several) to extends your own module inside:
```elixir
defmodule Foo do
  use ExHelpers.Binary
  
  # some extra-stuff
  # ..... 
end
Foo.to_s(1) # => "1"
```

- Just use all function from nested helpers inside your module by just calling from library:
```elixir
defmodule Foo do
  def bar(val), do: ExHelpers.to_s(val)
end
Foo.bar(1) # => "1"
``` 
This method of using also acceptable to single helper too: `ExHelpers.Binary.to_s(1) #=> "1""`

- Use all functions at once by single "use" of main module:
```elixir
defmodule Foo, do: use ExHelpers
Foo.to_f(1) # => 1.0
```

Currently available modules:
  - [ExHelpers.Binary](lib/ex_helpers/binary.ex)
  - [ExHelpers.DateTime](lib/ex_helpers/date_time.ex)
  - [ExHelpers.List](lib/ex_helpers/list.ex)
  - [ExHelpers.Map](lib/ex_helpers/map.ex)
  - [ExHelpers.Numeric](lib/ex_helpers/numeric.ex)

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_helpers](https://hexdocs.pm/ex_helpers).

