defmodule StringTest do
  use ExUnit.Case
  doctest ExHelpers.Binary
  alias ExHelpers.Binary
  use Binary

  describe "#to_s" do
    test "should be available through direct calling" do
      assert Binary.to_s("asd") == "asd"
    end
    test "should convert nil to binary" do
      assert to_s(nil) == ""
    end
    test "should convert integer to binary" do
      assert to_s(123) == "123"
    end
    test "should convert float to binary" do
      assert to_s(123.123) == "123.123"
    end
    test "should convert atom to binary" do
      assert to_s(:asd123) == "asd123"
    end
    test "should convert list to binary" do
      assert to_s([]) == "[]"
      assert to_s([1, :atom, "str", a: 1]) == "[1, :atom, \"str\", {:a, 1}]"
    end
    test "should convert map to binary" do
      assert to_s(%{}) == "%{}"
      assert to_s(%{"a"=>1, b: 2}) == "%{:b => 2, \"a\" => 1}"
    end
    test "should convert tuple to binary" do
      assert to_s({}) == "{}"
      assert to_s({"a", :b, 2}) == "{\"a\", :b, 2}"
    end
    test "should convert any given structure to binary" do
      assert to_s([{:a, 1}, [1,2, "123"]]) == "[{:a, 1}, [1, 2, \"123\"]]"
    end
  end

  describe "#select_longest_word" do
    test "should be available by through direct calling" do
      assert Binary.select_longest_word("") == nil
    end
    test "should return longest word" do
      assert select_longest_word("should  ; return longest     word  ") == "longest"
      assert select_longest_word(" should;return,longest.word   ") == "longest"
    end
    test "should return longest word by custom delimiter splitting" do
      assert select_longest_word("should return longest word", ~r/-/) == "should return longest word"
      assert select_longest_word("shoul-d -return longe-st word", ~r/-/) == "return longe"
      assert select_longest_word("should return longest word", "return") == " longest word"
    end
  end
end