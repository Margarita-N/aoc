defmodule Aoc.Days.Day7 do
  @part_1_operators ["+", "*"]
  @part_2_operators ["+", "*", "||"]

  def solution(input) do
    input
    |> Enum.reduce(0, fn {key, values}, acc ->
      if calculate_value(values, key) == :solved, do: acc + key, else: acc
    end)
  end

  def calculate_value([head | tail], value) do
    Enum.reduce_while(@part_2_operators, :unsolved, fn _, _ ->
      if calculate_value(tail, value, head) == :solved do
        {:halt, :solved}
      else
        {:cont, :unsolved}
      end
    end)
  end

  def calculate_value([], value, acc) when value == acc, do: :solved
  def calculate_value([], _, _), do: :unsolved
  def calculate_valueest(_values, value, acc) when acc > value, do: :unsolved

  def calculate_value([head | tail], value, acc) do
    Enum.reduce_while(@part_2_operators, :unsolved, fn operator, _ ->
      acc =
        case operator do
          "+" -> acc + head
          "*" -> acc * head
          "||" -> "#{acc}#{head}" |> String.to_integer()
        end

      if calculate_value(tail, value, acc) == :solved do
        {:halt, :solved}
      else
        {:cont, :unsolved}
      end
    end)
  end

  def parse_input() do
    {:ok, input} = File.read("lib/inputs/day_7.txt")

    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    [key, values] = String.split(line, ": ")

    {
      String.to_integer(key),
      values
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)
    }
  end
end
