defmodule Aoc do
  @moduledoc """
  Main module to run daily challenges
  """

  def run() do
    Aoc.Days.Day1.parse_input()
    |> Aoc.Days.Day1.solution_2()
  end
end
