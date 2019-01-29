defmodule ExHelpers.Map do
  @moduledoc """
  Contain some functions to manipulating with map

  Can be imported as external module inside yours for some internal
  needs or may extends functionality with functions here:
  ```
  # import for using inside module
  defmodule A do
    import ExHelpers.Map

    def foo(val), do: map_keys_to_s(val)
  end
  A.foo(%{}) # => %{}

  # extends module with functionality of helper
  defmodule B, do: use ExHelpers.Map
  B.map_keys_to_s(%{}) # => %{}
  ```
  """
  import ExHelpers.Numeric, only: [to_i: 1]

  @doc """
  Converts map keys to binary.

  Inner maps, which is values for original map, will be also converted recursively if type of value is map.

  ```
  map_keys_to_s(%{1=>"a", :a=>1, b: {1, 2}, c: %{a: 1}}) # => %{"1" => "a", "a" => 1, "b" => {1, 2}, "c" => %{a: 1}}
  ```
  """
  def map_keys_to_s(map) do
    for {key, val} <- map, into: %{} do
      {to_string(key), (if is_map(val), do: map_keys_to_s(val), else: val)}
    end
  end

  @doc """
  Find value where keys are ranges.

  ```
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
  find_by_range_including(map, 710) # => 0.038
  find_by_range_including(map, 710.0) # => 0.038
  find_by_range_including(map, 786) # => 0.022
  find_by_range_including(map, 786.5) # => 0.014
  find_by_range_including(map, 9000) # => 0.002
  find_by_range_including(map, -1) # => nil
  ```
  """
  def find_by_range_including(map, value) do
    key = Map.keys(map)
          |> Enum.find(&(Enum.member?(&1, to_i(value))))
    map[key]
  end

  @doc """
  Converts list of maps to map where keys are values from original by second params and values are original maps

  ```
  array_of_maps_to_map_with_key([%{"title" => "1", a: 1}, %{"title" => "2", b: 1}], "title") # => %{"1" => %{"title" => "1",a: 1}, "2" => %{"title" => "2",b: 1}}
  array_of_maps_to_map_with_key([%{"title" => "1", a: 1}, %{"title" => "2", b: 1}], :a) # => %{1 => %{:a => 1, "title" => "1"}, nil => %{b: 1, "title" => "2"}}
  ```
  """
  def array_of_maps_to_map_with_key(list, key) do
    list |> Enum.reduce(%{}, fn el, acc -> acc |> Map.put_new(el[key], el) end)
  end

  @doc """
  Returns value from map by string path - key defined with dot, where dot is new layer of map or list

  second argument - path - is always string
  ```
  get_by_flat_key(%{"a" => "b"}, "a") # => "b"
  get_by_flat_key(%{:a => "b"}, "a") # => "b"
  get_by_flat_key(%{:a => %{"a" => "b"}}, "a.a") # => "b"
  get_by_flat_key(%{:a => [%{"a" => "b"}, %{"A" => "B"}]}, "a.1.A") # => "B"
  get_by_flat_key(%{:a => [%{"a" => "b"}, %{"A" => "B"}]}, "a.2.A") # => nil
  get_by_flat_key(%{:a => [%{"a" => "b"}, %{"A" => [1, 2]}]}, "a.1.A.0") # => 1
  ```
  """
  def get_by_flat_key(nil, _path), do: nil
  def get_by_flat_key(hash, path) when is_binary(path), do: get_by_flat_key(hash, String.split(path, "."))
  def get_by_flat_key(hash, [leaf_key]) when is_map(hash), do: hash[leaf_key] || hash[String.to_atom(leaf_key)]
  def get_by_flat_key(list, [leaf_key]) when is_list(list), do: Enum.at(list, to_i(leaf_key))
  def get_by_flat_key(hash, [key | rest]) when is_map(hash) do
    new_hash = hash[key] || hash[String.to_atom(key)]
    get_by_flat_key(new_hash, rest)
  end
  def get_by_flat_key(list, [key | rest]) when is_list(list), do: get_by_flat_key(Enum.at(list, to_i(key)), rest)

  @doc """
  Update nested map with data by key like in `get_by_flat_key/2` (dot-splitted paths like "a.b", which means for example `%{"a"=>%{"b"=>1}}`)

  For empty map puts given value by given key in required place
  ```
  deep_update(%{}, "1", 1) # => %{"1" => 1}
  deep_update(%{"a" => "b", "z" => "Z"}, "a", "Y") # => %{"a" => "Y", "z" => "Z"}
  deep_update(%{"a" => [%{}]}, "a.0.b", 10) # => %{"a" => [%{"b" => 10}]}
  deep_update(%{}, "a.b", 10) # => %{"a" => %{"b" => 10}}
  deep_update(%{"a" => [0, 1, 2], "b" => "B"}, "a.0", 10) # => %{"a" => [10, 1, 2], "b" => "B"}
  deep_update(%{"a" => %{"b" => [%{"a" => [0, 1, 2], "b" => "B"}, 1, 2]}}, "a.b.0.a.0", 10) # => %{"a" => %{"b" => [%{"a" => [10, 1, 2], "b" => "B"}, 1, 2]}}
  ```
  """
  def deep_update(map, path, value) when is_binary(path), do: deep_update(map, String.split(path, "."), value)
  def deep_update(map, [leaf_key], value) when is_map(map), do: Map.put(map, leaf_key, value)
  def deep_update(list, [leaf_key], value) when is_list(list), do: List.update_at(list, to_i(leaf_key), fn _ -> value end)
  def deep_update(map, [key | key_tail], value) when is_map(map) do
    new_branch = deep_update(map[key] || %{}, key_tail, value)
    Map.put(map, key, new_branch)
  end
  def deep_update(list, [key | key_tail], value) when is_list(list) do
    index = to_i(key)
    list_element = Enum.at(list, index)
    new_branch = deep_update(list_element, key_tail, value)
    List.update_at(list, index, fn _ -> new_branch end)
  end

  defmacro __using__(_opts) do
    quote do
      defdelegate map_keys_to_s(m), to: ExHelpers.Map
      defdelegate find_by_range_including(m, v), to: ExHelpers.Map
      defdelegate array_of_maps_to_map_with_key(l, k), to: ExHelpers.Map
      defdelegate get_by_flat_key(m, k), to: ExHelpers.Map
      defdelegate deep_update(m, k, v), to: ExHelpers.Map
    end
  end
end