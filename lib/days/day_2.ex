defmodule Aoc.Days.Day2 do
  def solution_1(input) do
    Enum.reduce(input, 0, fn report, acc ->
      case validate_report_progress(report) do
        {_, 1} -> acc + 1
        {_, 0} -> acc
      end
    end)
  end

  defp validate_report_progress(report = [head | [compare | _tail]]) do
    is_valid =
      find_trend(head - compare)
      |> validate_report_progress(report)

    {report, is_valid}
  end

  defp validate_report_progress(trend, report = [head | [compare | tail]])
       when length(report) >= 2 do
    case ((head - compare) * trend) in [-1, -2, -3] do
      true ->
        validate_report_progress(trend, [compare | tail])

      false ->
        0
    end
  end

  defp validate_report_progress(_, report) when length(report) == 1, do: 1
  defp validate_report_progress(_, _), do: 0

  # decreasing
  defp find_trend(trend) when trend > 0, do: -1
  # increasing
  defp find_trend(_trend), do: 1

  def solution_2(input) do
    result = Enum.map(input, &validate_report_progress/1)

    safe_unsafe =
      result
      |> Enum.filter(fn {_, is_valid} -> is_valid == 0 end)
      |> Enum.reduce(0, fn {report, _}, acc ->
        case check_error_levels(report, 0) do
          :safe -> acc + 1
          :unsafe -> acc
        end
      end)

    safe =
      result
      |> Enum.filter(fn {_, is_valid} -> is_valid == 1 end)
      |> Enum.count()

    safe + safe_unsafe
  end

  def check_error_levels(report, index) when index == length(report), do: :unsafe

  def check_error_levels(report, index) do
    report
    |> List.delete_at(index)
    |> validate_report_progress()
    |> case do
      {_, 1} ->
        # at least once is safe
        :safe

      {_, 0} ->
        check_error_levels(report, index + 1)
    end
  end

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
