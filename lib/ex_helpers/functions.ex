defmodule ExHelpers.Functions do
  @moduledoc """
  Module with function wrappers.

  Currently available only `recursive_with_timeout/4`.

  **TODO: async wrappers**
  """

  @doc """
  Recursive function call until result is given or timeout reached.

  It is a wrapper function around executable anonymous function with timeout.
  It's useful when you need to try execute some code or pass after some seconds of trying. For example,
  if you need to fetch available worker in pool.

  Simple example:
  ```
  fun = fn->
    # some logic inside
    {:ok, __MODULE__}
  end
  time_to_exit = Timex.shift(Timex.now, seconds: 10)
  # trying for 10 seconds after first call or if result is given in this timeout
  recursive_with_timeout(fun, time_to_exit)
  ```

  There is some limitation:
  1. exit_time - variable of type `DateTime.t()`, when is reached without proper result, function stops.
  2. fn_to_call - anonymous function (closure) with code to execute.
  Should return tuple `{:ok, <anything>}` for proper exit or `{:error, <anything>}` for next call in wrapper.
  If return spec is not like one of this, wrapper will return `{:error, :wrong_function_spec, <result of first call>}`
  without further recursive calls.

  You can customize timeout return message with argument `error_msg` - it will give you `{:error, <error_msg>}`
  if timeout is reached. By default `error_msg=:timeout_reached`

  You can customize timeout between recursive calls of closure with argument `sleep_before_call_in_ms`,
  by default it's 100 milliseconds.
  """
  @spec recursive_with_timeout(fun, integer, any) :: {:ok, any} | {:error, any} | {:error, any, any}
  def recursive_with_timeout(fn_to_call, exit_time, error_msg \\ :timeout_reached, sleep_before_call_in_ms \\ 100) do
    case Timex.compare(Timex.now, exit_time) do
      # when exit_time isn't reached yet - call function (again or first time)
      (-1) ->
        case fn_to_call.() do
          # tuple like {:ok, _} is good return value - return it in result.
          {:ok, result} -> {:ok, result}
          # tuple {:error, _} means that we need to call it again after sleep_before_call_in_ms
          {:error, _} ->
            :timer.sleep(sleep_before_call_in_ms)
            recursive_with_timeout(fn_to_call, exit_time, error_msg)
          # if return value is none of tuples above - it is wrong specification and we don't need to call it again, just
          # return what we get from closure.
          res -> {:error, :wrong_function_spec, res}
        end
      # when exit_time is reached, we don't need to call closure
      _gt_or_eq -> {:error, error_msg}
    end
  end

  defmacro __using__(_opts) do
    quote do
      defdelegate recursive_with_timeout(fn_to_call, exit_time),
                  to: ExHelpers.Functions
      defdelegate recursive_with_timeout(fn_to_call, exit_time, error_msg),
                  to: ExHelpers.Functions
      defdelegate recursive_with_timeout(fn_to_call, exit_time, error_msg, sleep_before_call_in_ms),
                  to: ExHelpers.Functions
    end
  end
end