defmodule ExHelpers.DateTime do
  @moduledoc """
  Module contain functions to convert any (almost of it, for string patterns take a look at `to_date/1`)
  date/datetime strings to date and wrappers around `Timex.shift/2` for shorter shift datetime declaration.

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

  use Memoize

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
  defmemo to_date(nil), expires_in: 5 * 60 * 1000 do
    nil
  end
  defmemo to_date(""), expires_in: 5 * 60 * 1000 do
    nil
  end
  defmemo to_date(prop), expires_in: 5 * 60 * 1000 do
    to_date(prop, @patterns)
  end
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
  defmemo to_date(nil, _), expires_in: 5 * 60 * 1000 do
    nil
  end
  defmemo to_date("", _), expires_in: 5 * 60 * 1000 do
    nil
  end
  defmemo to_date(prop, pattern) when is_binary(pattern), expires_in: 5 * 60 * 1000 do
    to_date(prop, [pattern])
  end
  defmemo to_date(prop, patterns) when is_list(patterns), expires_in: 5 * 60 * 1000 do
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
  defmemo to_date(_, _), expires_in: 5 * 60 * 1000  do
    nil
  end

  @doc """
  take a look at `after_time/2`
  """
  @spec after_time(integer) :: DateTime.t() | {:error, any}
  def after_time(duration), do: after_time(duration, :seconds)
  @doc """
  Simple wrapper around `Timex.shift/2`.

  Returns forward shift by `duration` in `granularity`.

  - duration - integer value, > 0
  - granularity - granularity metric, look at `Timex.Comparable.granularity/0`. `:seconds` by default

  Examples:
  ```
  after_time(5) # => 5 secs in future relatively Timex.now
  after_time(5, :days) # => 5 days in future relatively Timex.now
  ```
  """
  @spec after_time(integer, atom) :: DateTime.t() | {:error, any}
  def after_time(duration, _) when duration < 1, do: {:error, :wrong_duration}
  def after_time(duration, granularity), do: Timex.shift(Timex.now, [{granularity, duration}])

  @doc """
  take a look at `before_time/2`
  """
  @spec before_time(integer) :: DateTime.t() | {:error, any}
  def before_time(duration), do: before_time(duration, :seconds)
  @doc """
  Simple wrapper around `Timex.shift/2`.

  Similar to `after_time/2`.

  Returns backward shift by `duration` in `granularity`.

  - duration - integer value, > 0
  - granularity - granularity metric, look at `Timex.Comparable.granularity/0`. `:seconds` by default

  Examples:
  ```
  before_time(5) # => 5 secs in past relatively Timex.now
  before_time(5, :days) # => 5 days in past relatively Timex.now
  ```
  """
  @spec before_time(integer, atom) :: DateTime.t() | {:error, any}
  def before_time(duration, _) when duration < 1, do: {:error, :wrong_duration}
  def before_time(duration, granularity) do
    case is_integer(duration) do
      true -> Timex.shift(Timex.now, [{granularity, -duration}])
      false -> {:error, {:invalid_shift, {granularity, duration}}}
    end
  end

  defmacro __using__(_opts) do
    quote do
      defdelegate to_date(prop), to: ExHelpers.DateTime
      defdelegate to_date(prop, patterns), to: ExHelpers.DateTime
      defdelegate after_time(duration), to: ExHelpers.DateTime
      defdelegate after_time(duration, granularity), to: ExHelpers.DateTime
      defdelegate before_time(duration), to: ExHelpers.DateTime
      defdelegate before_time(duration, granularity), to: ExHelpers.DateTime
    end
  end
end