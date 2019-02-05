defmodule ListTest do
  use ExUnit.Case
  doctest ExHelpers.List
  alias ExHelpers.List
  use List

  describe "#always_list" do
    test "should be available through direct calling" do
      assert List.always_list("asd") == ["asd"]
    end
    test "should wrap to list any type" do
      assert always_list(%{a: 1}) == [%{a: 1}]
      assert always_list({:a, 1, "aaa"}) == [{:a, 1, "aaa"}]
      assert always_list(nil) == []
      assert always_list(123) == [123]
      assert always_list("123") == ["123"]
    end
    test "should not wrap to list a list itself" do
      assert always_list([]) == []
      assert always_list([:a, 1, 5, {1, 2}]) == [:a, 1, 5, {1, 2}]
      assert always_list([a: 1, b: 2]) == [a: 1, b: 2]
      assert always_list([a: 1, b: 2, c: %{a: 1}]) == [a: 1, b: 2, c: %{a: 1}]
    end
  end
  describe "#transpose" do
    test "should be available through direct calling" do
      assert List.transpose([]) == []
    end
    test "should transpose matrix" do
      assert transpose([[1,2,"1"]]) == [[1], [2], ["1"]]
      assert transpose([[1,2,"1"],[5,7,9]]) == [[1, 5], [2, 7], ["1", 9]]
    end
  end

  describe "#hash_to_csv_header_array" do
    test "should be available through direct calling" do
      assert List.hash_to_csv_header_array(%{}) == []
    end
    test "should convert all map keys to sorted in lexicographical order list" do
      assert hash_to_csv_header_array(%{"c" => 1, "b" => 2, "a" => 3}) == ["a", "b", "c"]
    end

    test "should convert inner maps to flat list" do
      assert hash_to_csv_header_array(
               %{
                 "c" => 1,
                 "b" => 2,
                 "a" => %{
                   "c" => 1,
                   "b" => 2,
                   "a" => 3
                 }
               }
             ) == ["a.a", "a.b", "a.c", "b", "c"]
    end

    test "should convert with date inside" do
      assert hash_to_csv_header_array(
               %{
                 "c" => ~D[2018-01-01],
                 "b" => 2,
                 "a" => %{
                   "c" => 1,
                   "b" => ~N[2018-12-29 06:18:55],
                   "a" => 3
                 }
               }
             ) == ["a.a", "a.b", "a.c", "b", "c"]
    end
  end

  describe "#hash_to_csv_data_array" do
    test "should be available through direct calling" do
      assert List.hash_to_csv_data_array(%{}, []) == []
    end
    test "should return values list by header with complex keys in header passed" do
      map = %{"c" => 1, "b" => 2, "a" => %{"c" => ~D[2018-01-01], "b" => ~N[2018-12-29 06:18:55], "a" => 3}, "555" => [{1, 2}, {2, 2}]}
      header = ["a.c", "a.b", "a.p", "c", "1", "555", "no_definition"]
      assert hash_to_csv_data_array(map, header) == [~D[2018-01-01], ~N[2018-12-29 06:18:55], nil, 1, nil, [{1, 2}, {2, 2}], nil]
    end
  end

  describe "#cut_subarrays_to_same_size" do
    test "should be available through direct calling" do
      assert List.cut_subarrays_to_same_size([[]]) == [[]]
    end
    test "should cut inner lists to same size by min-sized list inside" do
      assert cut_subarrays_to_same_size([[1,2,3],[1,2,3,4],[2,2]]) == [[1, 2], [1, 2], [2, 2]]
      assert cut_subarrays_to_same_size([[1,2,3],[5,6,7,8]]) == [[1, 2, 3], [5,6,7]]
      assert cut_subarrays_to_same_size([[1,2,3],[5,6,7,8],[]]) == [[], [], []]
    end
  end
end