defmodule Aoc.Days.Day5 do
  def solution_1({rules, rows}) do
    parsed_rules =
      rules
      |> parse_rules()

    parsed_rules
    |> get_unique_elements()
    |> assert_sorting(parsed_rules)
    # |> validate_rows(rows)
  end

  defp assert_sorting(unique_elements, []), do: unique_elements
  defp assert_sorting(unique_elements, [head | tail]) do
    {elem_1, elem_2} = head

    index_1 = Enum.find_index(unique_elements, fn x -> x == elem_1 end)
    index_2 = Enum.find_index(unique_elements, fn x -> x == elem_2 end)

    unique_elements =
      if index_1 > index_2 do
        List.replace_at(unique_elements, index_1, elem_2)
        |> List.replace_at(index_2, elem_1)
      else
        unique_elements
      end

    assert_sorting(unique_elements, tail)
  end

  defp validate_rows(sorted_elements, rows) do
    rows
    |> parse_rows()
    |> Enum.reduce(0, fn row, acc ->
      difference = sorted_elements -- row

      if sorted_elements -- difference == row do
        acc + find_middle(row)
      else
        acc
      end
    end)
  end

  defp get_unique_elements(input) do
    input
    |> Enum.flat_map(fn {a,b} -> [a,b] end)
    |> Enum.uniq()
  end

  defp find_middle(row), do: Enum.at(row, div(length(row), 2))

  def parse_input do
    {:ok, input} = File.read("lib/inputs/day_5.txt")

    {rules, [_separator | rows]} =
      String.split(input, "\n")
      |> Enum.split_while(fn x -> x != "" end)

    {rules, rows}
  end

  def parse_rules([]), do: []
  def parse_rules([head | tail]) do
    [elem_1, elem_2] =
      head
      |> String.split("|")
      |> Enum.map(&String.to_integer/1)

    [{elem_1, elem_2} | parse_rules(tail)]
  end

  defp parse_rows([]), do: []
  defp parse_rows([head | tail]) do
    parsed_list =
      head
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    [ parsed_list | parse_rows(tail)]
  end
end
