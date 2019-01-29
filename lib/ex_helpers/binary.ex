defmodule ExHelpers.Binary do
  @moduledoc """
  Module contain functions for checking something in binary or to convert anything to binary

  Can be imported as external module inside yours for some internal
  needs or may extends functionality with functions here:
  ```
  # import for using inside module
  defmodule A do
    import ExHelpers.Binary

    def foo(val), do: to_s(val)
  end
  A.foo(1) # => "1"

  # extends module with functionality of helper
  defmodule B, do: use ExHelpers.Binary
  B.to_s(1) # => "1"
  ```
  """

  @doc """
  Convert everything to binary

  ```
  to_s(nil) # => ""
  to_s("") # => ""
  to_s("asd") # => "asd"
  to_s(:asd) # => "asd"
  to_s(123) # => "123"
  to_s(123.123) # => "123.123"
  to_s([{:a, 1}, [1,2, "123"]]) # => "[{:a, 1}, [1, 2, \"123\"]]"
  ```
  """
  def to_s(nil), do: ""
  def to_s(str) when is_binary(str), do: str
  def to_s(atom) when is_atom(atom), do: Atom.to_string(atom)
  def to_s(int) when is_integer(int), do: Integer.to_string(int)
  def to_s(float) when is_float(float), do: Float.to_string(float)
  def to_s(smth), do: Kernel.inspect(smth, limit: :infinity)

  @doc """
  return longest word in binary or nil for empty string or nil

  uses as delimeters `~r/[ ;,.]/` by default (any given symble in "[]" regex can be delimiter),
  but you can override it through `select_longest_word/2`
  """
  def select_longest_word(str), do: select_longest_word(str, ~r/[ ;,.]/)
  @doc """
  same as `select_longest_word/1`, but second param used for custom delimiter (any valid regex or binary)

  ```
  select_longest_word("should return longest word", ~r/-/) # => "should return longest word"
  select_longest_word("shoul-d -return longe-st word", ~r/-/) # => "return longe"
  select_longest_word("should return longest word", "return") # => " longest word"
  ```
  """
  def select_longest_word(nil, _), do: ""
  def select_longest_word(str, delimiters) do
    str
    |> String.split(delimiters, trim: true)
    |> Enum.sort_by(& String.length/1)
    |> Enum.at(-1)
  end

  defmacro __using__(_opts) do
    quote do
      defdelegate to_s(v), to: ExHelpers.Binary
      defdelegate select_longest_word(v), to: ExHelpers.Binary
      defdelegate select_longest_word(v, d), to: ExHelpers.Binary
    end
  end
end