defmodule Aoc.Days.Day3 do
  def solution_1(input) do
    Regex.scan(~r/mul\(\d{1,3},\d{1,3}\)/, input)
    |> Enum.flat_map(fn x -> x end)
    |> Enum.reduce(0, fn expression, acc ->
      extract_and_multiply(expression) + acc
    end)
  end

  def solution_2(input) do
    [head | tail] = String.split(input, "don't()")

    head
    # first element is always included
    |> solution_1()
    |> add(exclude_disabled_multiplications(tail))
  end

  defp exclude_disabled_multiplications(expressions) do
    expressions
    |> Enum.reduce(0, fn x, acc ->
      [_excluded | included] = String.split(x, "do()")

      included
      |> List.to_string()
      |> solution_1()
      |> add(acc)
    end)
  end

  defp extract_and_multiply(expression) do
    Regex.scan(~r/\d{1,3}/, expression)
    |> Enum.flat_map(fn x -> x end)
    |> Enum.reduce(1, fn x, acc -> String.to_integer(x) * acc end)
  end

  defp add(a, b), do: a + b

  def parse_input do
    {:ok, input} = File.read("lib/inputs/day_3.txt")

    input
  end
end
