defmodule Aoc.Days.Day1 do
  def solution_1({base, compare}) do
    base_array = base |> Enum.sort()
    compare_array = compare |> Enum.sort()

    Enum.zip(base_array, compare_array)
    |> Enum.reduce(0, fn {x, y}, acc -> abs(x - y) + acc end)
  end

  def solution_2({base, compare}) do
    base_array = base |> Enum.sort()
    compare_array = compare |> Enum.sort()

    Enum.reduce(base_array, 0, fn x, acc -> compare_base(x, compare_array, acc) end)
  end

  defp compare_base(x, [head | tail], acc) when x > head, do: compare_base(x, tail, acc)
  defp compare_base(x, [head | tail], acc) when x == head, do: compare_base(x, tail, acc + x)
  defp compare_base(_, _, acc), do: acc

  def parse_input do
    {:ok, contents} = File.read("lib/inputs/day_1.txt")

    String.split(contents, "\n")
    |> parse_row([], [])
  end

  defp parse_row([], base, compare) do
    {base, compare}
  end

  defp parse_row([head | body], base, compare) do
    [first, second] = String.split(head, " ", trim: true) |> Enum.map(&String.to_integer/1)

    parse_row(body, [first | base], [second | compare])
  end
end
