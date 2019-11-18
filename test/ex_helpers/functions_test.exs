defmodule FunctionsTest do
  use ExUnit.Case
  doctest ExHelpers.Functions
  alias ExHelpers.Functions
  alias ExHelpers.DateTime
  use Functions

  describe "#recursive_with_timeout" do
    test "should return closure result" do
      fun = fn-> {:ok, __MODULE__} end
      before_exec = Timex.now
      seconds_to_exec = 10
      assert recursive_with_timeout(fun, DateTime.after_time(seconds_to_exec)) == {:ok, __MODULE__}
      after_exec = Timex.now
      assert Timex.diff(before_exec, after_exec, :seconds) <= seconds_to_exec
    end

    test "should stop after exit time is reached" do
      fun = fn-> {:error, "nomatter"} end
      before_exec = Timex.now
      seconds_to_exec = 3
      upto = DateTime.after_time(seconds_to_exec)
      assert recursive_with_timeout(fun, upto) == {:error, :timeout_reached}
      after_exec = Timex.now
      assert Timex.diff(before_exec, after_exec, :seconds) <= seconds_to_exec
      assert recursive_with_timeout(fun, upto, "custom_error") == {:error, "custom_error"}
    end

    test "should return timeout_reached for exit_time in past" do
      assert recursive_with_timeout(
               fn-> {:error, 1} end,
               Timex.parse("2010-10-01", "{YYYY}-{0M}-{D}")
             ) == {:error, :timeout_reached}
    end

    test "should return specification error if closure return value isn't matches by pattern" do
      fun = fn-> "wrong return pattern" end
      before_exec = Timex.now
      seconds_to_exec = 10
      assert recursive_with_timeout(fun, DateTime.after_time(seconds_to_exec)) == {
               :error,
               :wrong_function_spec,
               "wrong return pattern"
             }
      after_exec = Timex.now
      assert Timex.diff(before_exec, after_exec, :seconds) <= seconds_to_exec
    end
  end
end