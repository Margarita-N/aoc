defmodule Aoc.Days.Day8 do
  @grid_size 50

  def solution_1(input) do
    input
    |> get_signals()
    |> permutate_signals()
    |> generate_antinodes(:part_1)
    |> Enum.count()
  end

  def solution_2(input) do
    input
    |> get_signals()
    |> permutate_signals()
    |> generate_antinodes(:part_2)
    |> Enum.count()
  end

  defp get_signals(input) do
    for {row, i} <- Enum.with_index(input),
        {elem, j} <- Enum.with_index(row),
        elem != ".", do: {elem, {i,j}}
  end

  def permutate_signals(signals) do
    signals
    |> Enum.group_by(fn {signal, {x,y}} -> signal end)
    |> Enum.reduce([], fn {signal, positions}, acc ->
      [permutate_same_signals(positions) | acc]
    end)
    |> Enum.flat_map(fn x -> x end)
  end

  def permutate_same_signals(positions) do
    Enum.reduce(positions, [], fn {_, {x,y}}, acc ->
      [Enum.map(positions, fn {_, {x1,y1}} ->
        if x != x1 && y != y1 do
          {{x,y}, {x1, y1}}
        end
      end)
      |> Enum.filter(fn x -> x != nil end) | acc]
    end)
    |> Enum.flat_map(fn x -> x end)
  end

  defp generate_antinodes(combinations, :part_1) do
    Enum.reduce(combinations, [], fn {{x,y}, {a,b}}, acc ->
      row_diff = x - a
      col_diff = y - b

      [{x + row_diff, y + col_diff}, {a - row_diff, b - col_diff} | acc]
    end)
    |> Enum.uniq()
    |> Enum.filter(fn {x,y} -> x >= 0 && x < @grid_size && y >= 0 && y < @grid_size end)
  end

  defp generate_antinodes(combinations, :part_2) do
    Enum.reduce(combinations, [], fn {{x,y}, {a,b}}, acc ->
      row_diff = x - a
      col_diff = y - b

      result = generate_sequencial_nodes({x,y}, row_diff, col_diff)
      ++ generate_sequencial_nodes({a,b}, row_diff * -1, col_diff * -1)
      ++ [{x,y}, {a,b}]

      [result | acc]
    end)
    |> Enum.flat_map(fn x -> x end)
    |> Enum.uniq()
    |> Enum.filter(fn {x,y} -> x >= 0 && x < @grid_size && y >= 0 && y < @grid_size end)
  end

  defp generate_sequencial_nodes({x,y}, row_diff, col_diff) do
    if Enum.any?([x + row_diff, y + col_diff], fn elem -> elem < 0 || elem >= @grid_size end) do
      []
    else
      first_new_node = {x + row_diff, y + col_diff}
      [first_new_node | generate_sequencial_nodes(first_new_node, row_diff, col_diff)]
    end
  end

  def parse_input do
    {:ok, input} = File.read("lib/inputs/day_8.txt")

    input
    |> String.split("\n", trim: true)
    |> parse_rows()
  end

  defp parse_rows([]), do: []
  defp parse_rows([head | tail]) do
    row =
      head
      |> String.split("", trim: true)

    [row | parse_rows(tail)]
  end
end
