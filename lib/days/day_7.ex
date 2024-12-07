defmodule Aoc.Days.Day7 do
  @part_1_operators ["+", "*"]
  @part_2_operators ["+", "*", "||"]

  def solution(input) do
    input
    |> Enum.reduce(0, fn {key, values}, acc ->
      if test(values, key) == :solved, do: acc + key, else: acc
    end)
  end

  def test([head | tail], value) do
    Enum.reduce_while(@part_2_operators, :unsolved, fn _, _ ->
      if test(tail, value, head) == :solved do
        {:halt, :solved}
      else
        {:cont, :unsolved}
      end
    end)
  end

  def test([], value, acc) when value == acc, do: :solved
  def test([], _, acc), do: :unsolved
  def test([head | tail], value, acc) do
    Enum.reduce_while(@part_2_operators, :unsolved, fn operator, _ ->
      acc =
        case operator do
          "+" -> acc + head
          "*" -> acc * head
          "||" -> "#{acc}#{head}" |> String.to_integer()
        end

      if test(tail, value, acc) == :solved do
        {:halt, :solved}
      else
        {:cont, :unsolved}
      end
    end)
  end

  def parse_input() do
    {:ok, input} = File.read("lib/inputs/day_7.txt")

    input
    |> String.split("\n", trim: true) # Split into lines
    |> Enum.map(&parse_line/1)        # Parse each line
  end

  defp parse_line(line) do
    [key, values] = String.split(line, ": ") # Split by ": "
    {
      String.to_integer(key),                # Convert key to integer
      values
      |> String.split(" ")                  # Split the values by space
      |> Enum.map(&String.to_integer/1)     # Convert each value to integer
    }
  end
end
