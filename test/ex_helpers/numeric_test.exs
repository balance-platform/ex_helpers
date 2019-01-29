defmodule NumericTest do
  use ExUnit.Case
  doctest ExHelpers.Numeric
  alias ExHelpers.Numeric
  use Numeric

  describe "#to_i" do
    test "should be available through direct calling" do
      assert Numeric.to_i(nil) == 0
    end
    test "should convert any type of value except (map and list) to integer" do
      assert to_i(~D[2018-05-10]) == 20180510
      assert to_i(nil) == 0
      assert to_i(10) == 10
      assert to_i("10") == 10
      assert to_i(10.5) == 11
      assert to_i(10.4) == 10
    end
  end

  describe "#to_f" do
    test "should be available through direct calling" do
      assert Numeric.to_f(nil) == 0
    end
    test "should convert any type of value (except map, date, datetime, list) to integer" do
      assert to_f(1) == 1.0
      assert to_f("1") == 1.0
      assert to_f("1.0") == 1.0
      assert to_f(-1) == -1.0
      assert to_f("-1") == -1.0
      assert to_f("-1.0") == -1.0
      assert to_f(0) == 0.0
      assert to_f("0") == 0.0
      assert to_f("0.0") == 0.0
      assert to_f(5.2) == 5.2
      assert to_f("5.2") == 5.2
      assert to_f("-5.2") == -5.2
      assert to_f("-5.f2") == 0.0
      assert to_f("-5.2fff") == 0.0
      assert to_f(nil) == 0
      assert to_f("ывфафв") == 0
    end
  end

  describe "#is_numeric" do
    test "should be available through direct calling" do
      assert Numeric.is_numeric("asd") == false
    end
    test "should return true if binary is really numeric" do
      assert is_numeric("123") == true
      assert is_numeric("123.123") == true
    end
    test "should return false if binary isn't numeric" do
      assert is_numeric("") == false
      assert is_numeric("123.f") == false
    end
  end
end