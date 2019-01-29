defmodule ExHelpers do
  @moduledoc """
  This module provides way to extends your module by all of lib's helpers at once.

  Just add to your module `use ExHelpers`:
  ```
  defmodule Foo do
    use ExHelpers

    # some other stuff
    # .....
  end

  Foo.to_s(1) # => "1"
  ```

  Currently available modules:
  - [ExHelpers.Binary](ExHelpers.Binary.html)
  - [ExHelpers.DateTime](ExHelpers.DateTime.html)
  - [ExHelpers.List](ExHelpers.List.html)
  - [ExHelpers.Map](ExHelpers.Map.html)
  - [ExHelpers.Numeric](ExHelpers.Numeric.html)
  """

  use ExHelpers.Binary
  use ExHelpers.DateTime
  use ExHelpers.List
  use ExHelpers.Map
  use ExHelpers.Numeric

  defmacro __using__(_opts) do
    quote do
      use ExHelpers.Binary
      use ExHelpers.DateTime
      use ExHelpers.List
      use ExHelpers.Map
      use ExHelpers.Numeric
    end
  end
end
