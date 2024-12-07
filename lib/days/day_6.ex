defmodule Aoc.Days.Day6 do
  @grid_size 130

  def solution_1(input_grid) do
    [starting_point] = get_starting_point(input_grid)

    obstacles =
      get_obstacles(input_grid)
      |> Enum.flat_map(fn x -> x end)
      |> Enum.map(fn {i,j} -> {{i,j}, [0,0,0,0]} end)

    test(starting_point, obstacles, [])
    |> Enum.uniq()
    |> Enum.count()
  end

  def solution_2(input_grid) do
    [starting_point] = get_starting_point(input_grid)

    obstacles = get_obstacles(input_grid) |> Enum.flat_map(fn x -> x end) |> Enum.map(fn {i,j} -> {{i,j}, [0,0,0,0]} end)
    grid_length = Enum.count(input_grid)
    grid_width = Enum.at(input_grid, 0) |> Enum.count()

    test(starting_point, obstacles, [], grid_length, grid_width)
    |> Enum.uniq()
    |> remove_possible_obstacles_in_front(starting_point, obstacles)
    |> Enum.reduce(0, fn possible_obstacle, acc ->
      if test(starting_point, [{possible_obstacle, [0,0,0,0]} | obstacles], [], grid_length, grid_width) == :loop do
        acc + 1
      else
        acc
      end
    end)
  end

  defp remove_possible_obstacles_in_front(possible_obstacles, starting_point, obstacles) do
    {{x,y}, _} = starting_point

    {{i,j}, _} =
      Enum.filter(obstacles, fn {{i, j}, _} -> j == y and i < x end)
      |> Enum.sort_by(fn {{i,j}, _} -> i end)
      |> List.last()

    possible_obstacles -- get_positions({x,y}, {i,j})
  end

  defp test({starting_point, :up}, obstacles, walked_path) do
    {x,y} = starting_point

    Enum.filter(obstacles, fn {{i, j}, _} -> j == y and i < x end)
    |> Enum.sort_by(fn {{i,j}, _} -> i end)
    |> case do
      [] -> get_positions(starting_point, {0, y}) ++ walked_path
      sorted_obstacles ->
        {{x1,y1}, hit_count} = List.last(sorted_obstacles)

        walked_path = get_positions(starting_point, {x1+1,y1}) ++ walked_path
        if Enum.any?(hit_count, fn elem -> elem > 2 end) do
          :loop
        else
          updated_obstacles = update_obstacles({x1,y1}, obstacles, 0)
          test({{x1+1, y1}, :right}, updated_obstacles, walked_path, grid_length, grid_width)
        end

    end
  end

  defp test({starting_point, :down}, obstacles, walked_path) do
    {x,y} = starting_point
    Enum.filter(obstacles, fn {{i,j}, _} -> j == y and i > x end)
    |> Enum.sort_by(fn {{i,j}, _} -> i end)
    |> case do
      [] -> get_positions(starting_point, {grid_length - 1, y}) ++ walked_path
      sorted_obstacles ->
        {{x1,y1}, hit_count} = List.first(sorted_obstacles)

        walked_path = get_positions(starting_point, {x1-1, y1}) ++ walked_path
        if Enum.any?(hit_count, fn elem -> elem > 1 end)  do
          :loop
        else
          updated_obstacles = update_obstacles({x1,y1}, obstacles, 2)
          test({{x1-1, y1}, :left}, updated_obstacles, walked_path, grid_length, grid_width)
        end
    end
  end

  defp test({starting_point, :right}, obstacles, walked_path) do
    {x,y} = starting_point
    Enum.filter(obstacles, fn {{i, j}, _} -> i == x and j > y end)
    |> Enum.sort_by(fn {{i,j}, _} -> j end)
    |> case do
      [] -> get_positions(starting_point, {x, grid_width - 1}) ++ walked_path
      sorted_obstacles ->
        {{x1,y1}, hit_count} = List.first(sorted_obstacles)

        walked_path = get_positions(starting_point, {x1, y1-1}) ++ walked_path
        if Enum.any?(hit_count, fn elem -> elem > 1 end) do
          :loop
        else
          updated_obstacles = update_obstacles({x1,y1}, obstacles, 1)
          test({{x1, y1-1}, :down}, updated_obstacles, walked_path)
        end
    end
  end

  defp test({starting_point, :left}, obstacles, walked_path) do
    {x,y} = starting_point
    Enum.filter(obstacles, fn {{i, j}, _} -> i == x and j < y end)
    |> Enum.sort_by(fn {{i,j}, _} -> j end)
    |> case do
      [] -> get_positions(starting_point, {x, 0}) ++ walked_path
      sorted_obstacles ->
        {{x1,y1}, hit_count} = List.last(sorted_obstacles)

        walked_path = get_positions(starting_point, {x1, y1+1}) ++ walked_path
        if Enum.any?(hit_count, fn elem -> elem > 1 end) do
          :loop
        else
          updated_obstacles = update_obstacles({x1,y1}, obstacles, 3)
          test({{x1, y1+1}, :up}, updated_obstacles, walked_path, grid_length, grid_width)
        end
    end
  end

  def update_obstacles({x,y}, obstacles, side) do
    Enum.map(obstacles, fn {{i,j}, hit_count} ->
      if i == x and j == y do
        hit_count = List.replace_at(hit_count, side, Enum.at(hit_count, side) + 1)
        {{i,j}, hit_count}
      else
        {{i,j}, hit_count}
      end
    end)
  end

  defp get_positions({x,y}, {a,b}) when x == a do
    Enum.to_list(y..b)
    |> Enum.map(fn generated_coordinate -> {x, generated_coordinate} end)
  end

  defp get_positions({x,y}, {a,b}) when y == b do
    Enum.to_list(x..a)
    |> Enum.map(fn generated_coordinate -> {generated_coordinate, y} end)
  end

  def get_starting_point(matrix) do
    for {row, i} <- Enum.with_index(matrix),
        {elem, j} <- Enum.with_index(row),
        elem != "." and elem != "#",
        do: {{i, j}, get_direction(elem)}
  end

  defp get_obstacles(matrix) do
    obstacles = []
    for {row, i} <- Enum.with_index(matrix),
        {elem, j} <- Enum.with_index(row),
        elem == "#",
        do: obstacles = [{i, j} | obstacles]
  end

  defp get_direction(guard) do
    case guard do
      "^" -> :up
      "v" -> :down
      "<" -> :left
      ">" -> :right
    end
  end

  def parse_input do
    {:ok, input} = File.read("lib/inputs/day_6.txt")

    String.split(input, "\n")
    |> create_grid()
  end

  defp create_grid([]), do: []
  defp create_grid([head | tail]) do
    result =
      head
      |> String.split("", trim: true)

    [result | create_grid(tail)]
  end
end
