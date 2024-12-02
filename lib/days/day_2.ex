defmodule Aoc.Days.Day2 do
  def solution_1(input) do
    Enum.reduce(input, 0, fn report, acc -> acc + validate_report_progress(report) end)
  end

  defp validate_report_progress(report = [head | [compare | _tail]]) do
    find_trend(head - compare)
    |> validate_report_progress(report)
  end

  defp validate_report_progress(trend, report = [head | [compare | tail]]) when length(report) >= 2 do
    case (head - compare) * trend in [-1, -2, -3] do
      true ->
        validate_report_progress(trend, [compare | tail])
      false ->
        0
    end
  end

  defp validate_report_progress(_, report) when length(report) == 1, do: 1
  defp validate_report_progress(_, _), do: 0

  defp find_trend(trend) when trend > 0, do: -1 # decreasing
  defp find_trend(_trend), do: 1 # increasing

  def parse_input do
    {:ok, contents} = File.read("lib/inputs/day_2.txt")

    String.split(contents, "\n")
    |> parse_row()
  end

  defp parse_row([]), do: []
  defp parse_row([head | tail]) do
    [String.split(head, " ", trim: true) |> Enum.map(&String.to_integer/1) | parse_row(tail)]
  end
end
