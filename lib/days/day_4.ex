defmodule Aoc.Days.Day4 do
  @grid_size 140

  @letters ["X", "M", "A", "S"]

  def solution_1(input_matrix) do
    input_matrix
    |> get_coordinates_for_center_letter("X")
    |> Enum.flat_map(fn x -> x end)
    |> Enum.reduce(0, fn {i,j},acc ->
        acc + check_square(i, j, input_matrix)
    end)
  end

  def solution_2(input_matrix) do
    input_matrix
    |> get_coordinates_for_center_letter("A")
    |> Enum.flat_map(fn x -> x end)
    |> Enum.reduce(0, fn {i,j}, acc ->
      acc + check_xmas(i,j, input_matrix)
    end)
  end

  defp check_xmas(i,j,input_matrix) do
    elem_1 = get_at(input_matrix,i+1,j+1)
    elem_2 = get_at(input_matrix,i-1,j-1)

    elem_3 = get_at(input_matrix,i+1,j-1)
    elem_4 = get_at(input_matrix,i-1,j+1)

    if Enum.all?([elem_1,elem_2,elem_3,elem_4], fn x -> x != nil end) and
    ([elem_1, elem_2] |> Enum.sort() == ["M", "S"] and [elem_3, elem_4] |> Enum.sort() == ["M", "S"]) do
      1
    else
      0
    end
  end

  defp get_at(input_matrix,i,j) do
    if i >= 0 && i < @grid_size && j >= 0 && j < @grid_size do
      Enum.at(input_matrix, i) |> Enum.at(j)
    else
      nil
    end
  end

  def check_square(i, j, input_matrix) do
    generate_coordinates()
    |> Enum.reduce(0, fn {x,y}, acc ->
      if check_letter({i,j}, {x,y}, input_matrix, 1) == :match do
        acc + 1
      else
        acc
      end
    end)
  end

  def check_letter({i,j}, _, _, 4) when i >= 0 and i < @grid_size and j >= 0 and j < @grid_size do
    :match
  end

  def check_letter({i,j}, {x,y}, input_matrix, index) do
    {new_x, new_y} = {i+x,j+y}

    if new_x >= 0 and new_x < @grid_size and new_y >= 0 and new_y < @grid_size do
      if Enum.at(input_matrix, new_x) |> Enum.at(new_y) == Enum.at(@letters, index) do
        check_letter({new_x, new_y}, {x,y}, input_matrix, index+1)
      else
        :no_match
      end
    else
      :no_match
    end
  end

  def check_letter(_, _, _, _), do: :no_match

  def generate_coordinates do
    [
      {0, 0}, {0, 1}, {0, -1},
      {1, 0}, {1, 1}, {1, -1},
      {-1, 0}, {-1, 1}, {-1, -1}
    ]
  end

  def get_coordinates_for_center_letter(input_matrix, letter) do
    for {row, i} <- Enum.with_index(input_matrix) do
      for {elem, j} <- Enum.with_index(row),
      elem == letter, do: {i,j}
    end
  end

  def parse_input do
    {:ok, input} = File.read("lib/inputs/day_4.txt")

    String.split(input, "\n")
    |> make_matrix()
  end

  defp make_matrix([]), do: []
  defp make_matrix([head | tail]) do
    result =
      head
      |> String.split("", trim: true)

    [result | make_matrix(tail)]
  end
end
