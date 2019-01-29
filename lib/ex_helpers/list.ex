defmodule ExHelpers.List do
  @moduledoc """
  Module contain functions for receiving list or list operations.

  Can be imported as external module inside yours for some internal
  needs or may extends functionality with functions here:
  ```
  # import for using inside module
  defmodule A do
    import ExHelpers.List

    def foo(val), do: always_list(val)
  end
  A.foo(1) # => [1]

  # extends module with functionality of helper
  defmodule B, do: use ExHelpers.List
  B.always_list(1) # => [1]
  ```
  """

  @doc """
  wrap any type to list unless it is a list itself

  ```
  # any types and structures except lists will be wrapped up to list
  always_list(%{a: 1}) # => [%{a: 1}]
  always_list({:a, 1, "aaa"}) # => [{:a, 1, "aaa"}]
  always_list(nil) # => []
  always_list(123) # => [123]
  always_list("123") # => ["123"]

  # but lists itself are always list
  always_list([]) # => []
  always_list([:a, 1, 5, {1, 2}]) # => [:a, 1, 5, {1, 2}]
  always_list([a: 1, b: 2]) # => [a: 1, b: 2]
  always_list([a: 1, b: 2, c: %{a: 1}]) # => [a: 1, b: 2, c: %{a: 1}]
  ```
  """
  def always_list(el) when is_list(el) do el end
  def always_list(nil) do [] end
  def always_list(el) do [el] end

  @doc """
  Matrix transpose

  flips a matrix over its diagonal, that is it switches the row and column indices of the matrix by producing another matrix

  as argument should be passed empty list or list within list (square matrix)
  ```
  transpose([]) # => []
  transpose([[1,2,"1"]]) # => [[1], [2], ["1"]]
  transpose([[1,2,"1"],[5,7,9]]) # => [[1, 5], [2, 7], ["1", 9]]
  ```
  """
  def transpose([]), do: []
  def transpose([[]|_]), do: []
  def transpose(a) do
    [Enum.map(a, &hd/1) | transpose(Enum.map(a, &tl/1))]
  end

  @doc """
  Cut lists inside list to minimum-sized list

  ```
  cut_subarrays_to_same_size([[1,2,3],[1,2,3,4],[2,2]]) # => [[1, 2], [1, 2], [2, 2]]
  cut_subarrays_to_same_size([[1,2,3],[5,6,7,8]]) # => [[1, 2, 3], [5,6,7]]
  cut_subarrays_to_same_size([[1,2,3],[5,6,7,8],[]]) # => [[], [], []]
  ```
  """
  def cut_subarrays_to_same_size(matrix) do
    min_len = matrix
              |> Enum.map(&:erlang.length/1)
              |> Enum.min

    Enum.map(matrix, &Enum.take(&1, min_len))
  end

  @doc """
  Converts Map to list of csv-header-like dump, where keys of original map is header itself.

  Final list will be sorted in lexicographical order.
  For inner structures final header will be flat, header values will be defined through dot.

  ```
  hash_to_csv_header_array(%{"c" => 1, "b" => 2, "a" => 3}) # => ["a", "b", "c"]
  hash_to_csv_header_array(%{"c" => 1, "b" => 2, "a" => %{"c" => 1, "b" => 2, "a" => 3}}) # => ["a.a", "a.b", "a.c", "b", "c"]
  ```
  """
  def hash_to_csv_header_array(map) when is_map(map) do
    flatten_with_parent_key(map)
    |> Map.keys
    |> Enum.sort
  end

  @doc """
  Returns values from original map by header list its keys, like it returned from `hash_to_csv_header_array/1` on same map.

  Complex keys in `header_array`, defined through dot, will be correctly applied to inner structures.

  Not existed header keys will give nil in result.

  ```
  map = %{"c" => 1, "b" => 2, "a" => %{"c" => 1, "b" => 2, "a" => 3}, "555" => [{1, 2}, {2, 2}]}
  header = ["a.c", "a.b", "a.p", "c", "1", "555", "no_definition"]
  hash_to_csv_data_array(map, header) # => [1, 2, nil, 1, nil, [{1, 2}, {2, 2}], nil]
  ```
  """
  def hash_to_csv_data_array(map, header_array) do
    Enum.map(header_array, fn x ->
      [math_version_string | keys] = String.split("#{x}", ".")
      pop_in_key = [math_version_string] ++ keys
      {res, _} = pop_in(map, pop_in_key)
      res
    end)
  end

  defp flatten_with_parent_key(map) when is_map(map) do
    map
    |> Map.to_list()
    |> to_flat_map(%{})
  end
  defp to_flat_map([{pk, %Date{calendar: _, day: _, month: _, year: _} = v} | t], acc) do
    to_flat_map(t, Map.put_new(acc, pk, v))
  end
  defp to_flat_map([{pk, %{} = v} | t], acc) do
    v |> to_list(pk) |> to_flat_map(to_flat_map(t, acc))
  end
  defp to_flat_map([{k, v} | t], acc), do: to_flat_map(t, Map.put_new(acc, k, v))
  defp to_flat_map([], acc), do: acc

  defp to_list(map, pk) when is_atom(pk), do: to_list(map, Atom.to_string(pk))
  defp to_list(map, pk) when is_binary(pk), do: Enum.map(map, &update_key(pk, &1))
  defp to_list(map, pk) when is_integer(pk), do: Enum.map(map, &update_key(pk, &1))
  defp update_key(pk, {k, v} = _val) when is_atom(k), do: update_key(pk, {Atom.to_string(k), v})
  defp update_key(pk, {k, v} = _val) when is_binary(k), do: {"#{pk}.#{k}", v}

  defmacro __using__(_opts) do
    quote do
      defdelegate always_list(v), to: ExHelpers.List
      defdelegate transpose(v), to: ExHelpers.List
      defdelegate cut_subarrays_to_same_size(v), to: ExHelpers.List
      defdelegate hash_to_csv_header_array(m), to: ExHelpers.List
      defdelegate hash_to_csv_data_array(m, h), to: ExHelpers.List
    end
  end
end