defmodule Aoc.Days.Day9 do
  def solution_1(input) do
    count =
      input
      |> Enum.count()

    input
    |> test(0, -1 , 0, count)
  end

  defp test(_, start_index, end_index, acc, count) when start_index > (count + end_index), do: acc

  defp test(remaining_list = [head | tail], start_index, end_index, acc, count) when start_index <= (count + end_index) do
    IO.inspect({start_index, end_index, acc})
    if head == "." do
      if Enum.at(tail, end_index) != "." do
        test(tail, start_index + 1, end_index - 1, acc + (start_index * Enum.at(tail, end_index)))
      else
        test(remaining_list, start_index, end_index - 1, acc)
      end
    else
      test(tail, start_index + 1, end_index, acc + (start_index * head))
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
