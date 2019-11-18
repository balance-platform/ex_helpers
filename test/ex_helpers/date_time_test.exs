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

  describe "#after_time" do
    test "should return date later then now by duration" do
      assert Timex.shift(Timex.now, seconds: 5) <= after_time(5)
      assert Timex.shift(Timex.now, days: 5) <= after_time(5, :days)
    end
    test "should return error if duration or granularity is wrong to use" do
      assert after_time(0) == {:error, :wrong_duration}
      assert after_time(-1) == {:error, :wrong_duration}
      assert after_time("") == {:error, {:invalid_shift, {:seconds, ""}}}
      assert after_time(1, :ddd) == {:error, {:invalid_shift, {:ddd, 1}}}
    end
  end
  describe "#before_time" do
    test "should return date sooner then now by duration" do
      assert Timex.shift(Timex.now, seconds: -5) <= before_time(5)
      assert Timex.shift(Timex.now, days: -5) <= before_time(5, :days)
    end
    test "should return error if duration or granularity is wrong to use" do
      assert before_time(0) == {:error, :wrong_duration}
      assert before_time(-1) == {:error, :wrong_duration}
      assert before_time("") == {:error, {:invalid_shift, {:seconds, ""}}}
      assert before_time(1, :ddd) == {:error, {:invalid_shift, {:ddd, -1}}}
    end
  end
end