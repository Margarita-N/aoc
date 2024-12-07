defmodule Aoc.Days.Day6 do
  @grid_size 130

  def solution_1(input_grid) do
    [starting_point] = get_starting_point(input_grid)

    obstacles =
      get_obstacles(input_grid)
      |> Enum.flat_map(fn x -> x end)
      |> Enum.map(fn {i, j} -> {{i, j}, [0, 0, 0, 0]} end)

    move_guard(starting_point, obstacles, [])
    |> Enum.uniq()
    |> Enum.count()
  end

  def solution_2(input_grid) do
    [starting_point] = get_starting_point(input_grid)

    obstacles =
      get_obstacles(input_grid)
      |> Enum.flat_map(fn x -> x end)
      |> Enum.map(fn {i, j} -> {{i, j}, [0, 0, 0, 0]} end)

    move_guard(starting_point, obstacles, [])
    |> Enum.uniq()
    |> remove_possible_obstacles_in_front(starting_point, obstacles)
    |> Enum.reduce(0, fn possible_obstacle, acc ->
      if move_guard(starting_point, [{possible_obstacle, [0, 0, 0, 0]} | obstacles], []) == :loop do
        acc + 1
      else
        acc
      end
    end)
  end

  defp move_guard({{x, y}, direction}, obstacles, walked_path) do
    obstacles
    |> get_obstacles_in_front({x, y}, direction)
    |> sort_by_direction(direction)
    |> case do
      [] ->
        get_positions({x, y}, get_edge_position({x, y}, direction)) ++ walked_path

      sorted_obstacles ->
        {{x1, y1}, hit_count} = get_first_obstacle_in_front(sorted_obstacles, direction)

        if Enum.any?(hit_count, fn elem -> elem > 1 end) do
          :loop
        else
          {new_position, new_direction} = get_position_before_obstacle({x1, y1}, direction)
          walked_path = get_positions({x, y}, new_position) ++ walked_path
          updated_obstacles = update_obstacles({x1, y1}, obstacles, direction)

          move_guard({new_position, new_direction}, updated_obstacles, walked_path)
        end
    end
  end

  defp get_obstacles_in_front(obstacles, {x, y}, :up),
    do: Enum.filter(obstacles, fn {{i, j}, _} -> j == y and i < x end)

  defp get_obstacles_in_front(obstacles, {x, y}, :down),
    do: Enum.filter(obstacles, fn {{i, j}, _} -> j == y and i > x end)

  defp get_obstacles_in_front(obstacles, {x, y}, :right),
    do: Enum.filter(obstacles, fn {{i, j}, _} -> i == x and j > y end)

  defp get_obstacles_in_front(obstacles, {x, y}, :left),
    do: Enum.filter(obstacles, fn {{i, j}, _} -> i == x and j < y end)

  defp sort_by_direction(filtered_obstacles, direction) when direction in [:up, :down],
    do: Enum.sort_by(filtered_obstacles, fn {{i, _}, _} -> i end)

  defp sort_by_direction(filtered_obstacles, direction) when direction in [:right, :left],
    do: Enum.sort_by(filtered_obstacles, fn {{_, j}, _} -> j end)

  defp get_edge_position({_x, y}, :up), do: {0, y}
  defp get_edge_position({_x, y}, :down), do: {@grid_size - 1, y}
  defp get_edge_position({x, _y}, :right), do: {x, @grid_size - 1}
  defp get_edge_position({x, _y}, :left), do: {x, 0}

  defp get_first_obstacle_in_front(sorted_obstacles, direction) when direction in [:up, :left],
    do: List.last(sorted_obstacles)

  defp get_first_obstacle_in_front(sorted_obstacles, direction) when direction in [:down, :right],
    do: List.first(sorted_obstacles)

  defp get_position_before_obstacle({x, y}, :up), do: {{x + 1, y}, :right}
  defp get_position_before_obstacle({x, y}, :down), do: {{x - 1, y}, :left}
  defp get_position_before_obstacle({x, y}, :right), do: {{x, y - 1}, :down}
  defp get_position_before_obstacle({x, y}, :left), do: {{x, y + 1}, :up}

  defp remove_possible_obstacles_in_front(possible_obstacles, starting_point, obstacles) do
    {{x, y}, _} = starting_point

    {{i, j}, _} =
      Enum.filter(obstacles, fn {{i, j}, _} -> j == y and i < x end)
      |> Enum.sort_by(fn {{i, j}, _} -> i end)
      |> List.last()

    possible_obstacles -- get_positions({x, y}, {i, j})
  end

  defp update_obstacles(position, obstacles, :up), do: update_obstacles(position, obstacles, 0)
  defp update_obstacles(position, obstacles, :down), do: update_obstacles(position, obstacles, 2)
  defp update_obstacles(position, obstacles, :right), do: update_obstacles(position, obstacles, 1)
  defp update_obstacles(position, obstacles, :left), do: update_obstacles(position, obstacles, 3)

  defp update_obstacles({x, y}, obstacles, side) do
    Enum.map(obstacles, fn {{i, j}, hit_count} ->
      if i == x and j == y do
        hit_count = List.replace_at(hit_count, side, Enum.at(hit_count, side) + 1)
        {{i, j}, hit_count}
      else
        {{i, j}, hit_count}
      end
    end)
  end

  defp get_positions({x, y}, {a, b}) when x == a do
    Enum.to_list(y..b)
    |> Enum.map(fn generated_coordinate -> {x, generated_coordinate} end)
  end

  defp get_positions({x, y}, {a, b}) when y == b do
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
