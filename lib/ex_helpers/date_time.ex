defmodule ExHelpers.DateTime do
  @moduledoc """
  Currently module contain only one type of functions - convert any given binary to date.
  For parsing to date used Timex as most famous date/datetime library.

  **TODO: to_datetime functions**

  Module can be imported as external module inside yours for some internal
  needs or may extends functionality with functions here:
  ```
  # import for using inside module
  defmodule A do
    import ExHelpers.DateTime

    def foo(val), do: to_date(val)
  end
  A.foo(1) # => nil

  # extends module with functionality of helper
  defmodule B, do: use ExHelpers.DateTime
  B.to_date(1) # => nil
  ```
  """

  @patterns [
    "{YYYY}-{M}-{D}T{h24}:{m}:{s}{ss}Z",
    "{YYYY}-{M}-{D}T{h24}:{m}:{s}",
    "{D}.{M}.{YYYY}",
    "{YYYY}-{M}-{D}",
    "{YYYY}-{M}-{D} {h24}:{m}:{s}",
    "{YYYY}{M}{D}",
    "{YYYY}{M}{D}{h24}{m}{s}",
    "{D}/{M}/{YYYY}"
  ]
  @doc """
  Trying to parse any date/datetime binary to date.

  Defined patterns:
  ```
  #{Enum.join(@patterns, "\n")}
  ```

  for empty binary, nil, non-matched binary or integer/float return nil
  """
  def to_date(nil), do: nil
  def to_date(""), do: nil
  def to_date(prop), do: to_date(prop, @patterns)
  @doc """
  Parse to date with custom patterns.

  ```
  # there is no default patterns for this
  to_date("202012301800:00") # => nil
  # but with custom pattern defined it can be parsed
  to_date("202012301800:00", "{YYYY}{M}{D}{h24}{m}:{s}") # => ~D[2020-12-30]
  # it also may be list of multiple patterns
  to_date("2018-11-11", ["{YYYY}{M}{D}{h24}{m}:{s}", "{YYYY}-{M}-{D}"]) # => ~D[2018-11-11]
  to_date(nil, ["{YYYY}{M}{D}{h24}{m}:{s}"]) # => nil
  ```
  """
  def to_date(nil, _), do: nil
  def to_date("", _), do: nil
  def to_date(prop, pattern) when is_binary(pattern), do: to_date(prop, [pattern])
  def to_date(prop, patterns) when is_list(patterns) do
    patterns
    |> Enum.sort
    |> Enum.reverse
    |> Enum.map(fn(x) ->
      case Timex.parse(to_string(prop), x) do
        {:ok, res} -> Timex.to_date(res)
        _ -> nil
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.at(0)
  end
  def to_date(_, _), do: nil

  defmacro __using__(_opts) do
    quote do
      defdelegate to_date(prop), to: ExHelpers.DateTime
      defdelegate to_date(prop, patterns), to: ExHelpers.DateTime
    end
  end
end