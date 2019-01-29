defmodule ExHelpers.Numeric do
  @moduledoc """
  Module contain functions to convert value to integer or float and also check binary for numeric

  Can be imported as external module inside yours for some internal
  needs or may extends functionality with functions here:
  ```
  # import for using inside module
  defmodule A do
    import ExHelpers.Numeric

    def foo(val), do: to_i(val)
  end
  A.foo(1) # => 1

  # extends module with functionality of helper
  defmodule B, do: use ExHelpers.Numeric
  B.to_i(1) # => 1
  ```
  """

  @doc """
  check is numeric binary or not

  ```
  is_numeric("123.123") # => true
  is_numeric("123.12f3") # => false
  is_numeric("") # => false
  ```
  """
  def is_numeric(str) do
    case Float.parse(str) do
      {_num, ""} -> true
      _          -> false
    end
  end

  @doc """
  Convert any type of value (except list and map) to integer

  Date and datetime also will be converted to integer like YYYYMMDD, which kinda useful to comparasing

  For nil and empty binary returns 0

  ```
  to_i(~D[2018-05-10]) # => 20180510
  to_i(nil) # => 0
  to_i(10) # => 10
  to_i("10") # => 10
  to_i(10.5) # => 11
  to_i(10.4) # => 10
  ```
  """
  def to_i(nil), do: 0
  def to_i(""), do: 0
  def to_i("X"), do: 0
  def to_i(i) when is_integer(i), do: i
  def to_i(f) when is_float(f), do: round(f)
  def to_i(%Date{calendar: _, day: d, month: m, year: y}), do: d + m * 100 + y * 10_000
  def to_i(%DateTime{day: d, month: m, year: y}), do: d + m * 100 + y * 10_000
  def to_i(str), do: str |> String.split(".") |> Enum.at(0) |> String.to_integer

  @doc """
  Convert any type of value (except list, map and date/datetime) to float


  """
  def to_f(nil), do: 0.0
  def to_f("-"), do: 0.0
  def to_f(prop) when is_binary(prop) do
    case is_numeric(prop) do
      true -> prop |> Float.parse() |> elem(0)
      false -> 0.0
    end
  end
  def to_f(prop) when is_integer(prop), do: prop / 1
  def to_f(prop), do: prop

  defmacro __using__(_opts) do
    quote do
      defdelegate is_numeric(v), to: ExHelpers.Numeric
      defdelegate to_i(val), to: ExHelpers.Numeric
      defdelegate to_f(val), to: ExHelpers.Numeric
    end
  end
end