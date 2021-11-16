defmodule ExHelpersTest do
  use ExUnit.Case
  doctest ExHelpers
  use ExHelpers

  test "should use all of the functions in other modules from one use in main" do
    assert to_s(1) == "1"
  end
  test "should use functions of other modules of lib in user defined module by single use of ExHelpers" do
    defmodule A, do: use ExHelpers
    assert A.to_s(1) == "1"
  end
  test "should have use inside itself all of helpers" do
    assert to_s(1) == "1"
  end
  test "should import functions from helpers by import this module" do
    defmodule Foo do
      import ExHelpers
      def bar(val), do: to_s(val)
    end
    assert Foo.bar(1) == "1"
  end
end
