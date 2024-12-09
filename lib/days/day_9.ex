defmodule Aoc.Days.Day9 do
  def solution_1(input) do
    count =
      input
      |> Enum.count()

    input
    |> calculate_sum(0, -1 , 0, count)
  end

  defp calculate_sum(list, _, end_index, acc, _) when length(list) <= abs(end_index), do: acc
  defp calculate_sum(_, start_index, end_index, acc, count) when start_index > (count + end_index), do: acc

  defp calculate_sum(remaining_list = [head | tail], start_index, end_index, acc, count) when start_index <= (count + end_index) do
    if head == "." do
      if Enum.at(tail, end_index) != "." do
        calculate_sum(tail, start_index + 1, end_index - 1, acc + (start_index * Enum.at(tail, end_index)), count)
      else
        calculate_sum(remaining_list, start_index, end_index - 1, acc, count)
      end
    else
      calculate_sum(tail, start_index + 1, end_index, acc + (start_index * head), count)
    end
  end

  def parse_input do
    {:ok, input} = File.read("lib/inputs/day_9.txt")

    input
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> build_memory_map(:file, 0)
  end

  defp build_memory_map([], _, _), do: []
  defp build_memory_map([head | tail], :file, id) do
    List.duplicate(id, head) ++ build_memory_map(tail, :slot, id)
  end

  defp build_memory_map([head | tail], :slot, id) do
    List.duplicate(".", head) ++ build_memory_map(tail, :file, id + 1)
  end
end
