defmodule DateTimeTest do
  use ExUnit.Case
  doctest ExHelpers.DateTime
  alias ExHelpers.DateTime
  use DateTime

  describe "#to_date" do
    test "should be available through direct calling" do
      assert DateTime.to_date("asd") == nil
    end
    test "should parse datetime by default patterns" do
      assert to_date("2019-11-12 00:11:11") == ~D[2019-11-12]
      assert to_date("20201230180000") == ~D[2020-12-30]
    end
    test "should return nil for any non-datetime binary or other types" do
      assert to_date("") == nil
      assert to_date(nil) == nil
      assert to_date("123") == nil
      assert to_date(123) == nil
      assert to_date(123.111) == nil
    end
    test "should use custom patterns from second parametr" do
      assert to_date("202012301800:00") == nil
      assert to_date("202012301800:00", "{YYYY}{M}{D}{h24}{m}:{s}") == ~D[2020-12-30]
      assert to_date("202012301800:00", ["{YYYY}{M}{D}{h24}{m}:{s}"]) == ~D[2020-12-30]
      assert to_date("2018-11-11", ["{YYYY}{M}{D}{h24}{m}:{s}", "{YYYY}-{M}-{D}"]) == ~D[2018-11-11]
      assert to_date(nil, ["{YYYY}{M}{D}{h24}{m}:{s}"]) == nil
    end
    test "should return itself when argument is date already" do
      assert to_date(~D[2018-01-01]) == ~D[2018-01-01]
    end
  end
end