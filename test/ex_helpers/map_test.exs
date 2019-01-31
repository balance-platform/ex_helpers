defmodule MapTest do
  use ExUnit.Case
  doctest ExHelpers.Map
  alias ExHelpers.Map
  use Map

  describe "#map_keys_to_s" do
    test "should be available through direct calling" do
      assert Map.map_keys_to_s(%{}) == %{}
    end
    test "should convert all keys in map to string" do
      assert map_keys_to_s(
               %{
                 1 => "a",
                 :a => 1,
                 b: {1, 2},
                 c: %{
                   a: 1,
                   c: ~D[2019-01-01],
                   b: [1, %{a: 1}]
                 }
               }
             ) == %{
               "1" => "a",
               "a" => 1,
               "b" => {1, 2},
               "c" => %{
                 "a" => 1,
                 "c" => ~D[2019-01-01],
                 "b" => [1, %{a: 1}]
               }
             }
    end
  end

  describe "#find_by_range_including" do
    test "should be available through direct calling" do
      assert Map.find_by_range_including(%{}, 1) == nil
    end
    test "should return value for integer value in range keys" do
      map = %{
        0..708 => 0.122,
        709..758 => 0.038,
        759..786 => 0.022,
        787..804 => 0.014,
        805..826 => 0.012,
        827..845 => 0.01,
        846..851 => 0.008,
        852..874 => 0.006,
        875..894 => 0.004,
        895..9999 => 0.002,
      }
      assert find_by_range_including(map, 710) == 0.038
      assert find_by_range_including(map, 710.0) == 0.038
      assert find_by_range_including(map, 786) == 0.022
      assert find_by_range_including(map, 786.5) == 0.014
      assert find_by_range_including(map, 9000) == 0.002
      assert find_by_range_including(map, -1) == nil
    end
  end

  describe "#array_of_maps_to_map_with_key" do
    test "should be available through direct calling" do
      assert Map.array_of_maps_to_map_with_key(%{}, 1) == %{}
    end
    test "should convert list of maps to map by given key" do
      list = [%{"title" => "1", a: 1}, %{"title" => "2", b: 1}]
      assert array_of_maps_to_map_with_key(list, "title") == %{
               "1" => %{
                 "title" => "1",
                 a: 1
               },
               "2" => %{
                 "title" => "2",
                 b: 1
               }
             }
      assert array_of_maps_to_map_with_key(list, :a) == %{
               1 => %{:a => 1, "title" => "1"},
               nil => %{:b => 1, "title" => "2"}
             }
    end
  end

  describe "#get_by_flat_key" do
    test "should be available through direct calling" do
      assert Map.get_by_flat_key(%{}, "1") == nil
    end
    test "should find in flat map" do
      assert get_by_flat_key(%{"a" => "b"}, "a") == "b"
    end
    test "should find in flat map with atom key" do
      assert get_by_flat_key(%{:a => "b"}, "a") == "b"
    end
    test "should find in non-flat map" do
      assert get_by_flat_key(%{:a => %{"a" => "b"}}, "a.a") == "b"
    end
    test "should find in inner list too" do
      assert get_by_flat_key(%{:a => [%{"a" => "b"}, %{"A" => "B"}]}, "a.1.A") == "B"
    end
    test "should not fail to find in inner list where index more when list size" do
      assert get_by_flat_key(%{:a => [%{"a" => "b"}, %{"A" => "B"}]}, "a.2.A") == nil
    end
    test "should find even if last layer is list" do
      assert get_by_flat_key(%{:a => [%{"a" => "b"}, %{"A" => [1, 2]}]}, "a.1.A.0") == 1
    end
  end

  describe "#deep_update" do
    test "should be available through direct calling" do
      assert Map.deep_update(%{}, "1", 1) == %{"1" => 1}
    end
    test "should update flat map with given value by given key" do
      assert deep_update(%{"a" => "b", "z" => "Z"}, "a", "Y") == %{"a" => "Y", "z" => "Z"}
    end
    test "should update with given value by key in complex structure" do
      assert deep_update(%{"a" => [%{}]}, "a.0.b", 10) == %{"a" => [%{"b" => 10}]}
    end
    test "should put new values by key in empty map" do
      assert deep_update(%{}, "a.b", 10) == %{"a" => %{"b" => 10}}
    end
    test "should update value by key also in nested list too" do
      assert deep_update(%{"a" => [0, 1, 2], "b" => "B"}, "a.0", 10) == %{"a" => [10, 1, 2], "b" => "B"}
      assert deep_update(%{"a" => %{"b" => [%{"a" => [0, 1, 2], "b" => "B"}, 1, 2]}}, "a.b.0.a.0", 10) == %{"a" => %{"b" => [%{"a" => [10, 1, 2], "b" => "B"}, 1, 2]}}
    end
  end
end