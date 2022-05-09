defmodule ReportsGenerator do
  alias ReportsGenerator.Parser

  @available_foods [
    "açaí",
    "churrasco",
    "esfirra",
    "hambúrguer",
    "pastel",
    "pizza",
    "prato_feito",
    "sushi"
  ]

  @options ["foods", "users"]

  def build(filename) do
    filename
    |> ReportsGenerator.Parser.parse_file()
    |> Enum.reduce(reports_acc(), fn line, report -> sum_values_per_user(line, report) end)
  end

  def build_from_many(filenames) do
    filenames
    |> Task.async_stream(&build/1)
    |> Enum.reduce(reports_acc(), fn {:ok, result}, report -> sum_reports(report, result) end)
  end

  def fetch_higher_cost(report, option) when option in @options,
    do: {:ok, Enum.max_by(report[option], fn {_key, value} -> value end)}

  def fetch_higher_cost(_report, _option), do: {:error, "Invalid option!"}

  defp reports_acc do
    foods = Enum.into(@available_foods, %{}, &{&1, 0})
    users = Enum.into(1..30, %{}, &{Integer.to_string(&1), 0})

    %{"users" => users, "foods" => foods}
  end

  defp sum_reports(%{"foods" => foods1, "users"=> users1}, %{"foods"=> foods2, "users" => users2}) do
    foods = merge_maps_and_sum(foods1, foods2)
    users = merge_maps_and_sum(users1, users2)

    %{"foods"=> foods, "users"=>users}
  end

  defp merge_maps_and_sum(map1,map2) do
    Map.merge(map1,map2, fn _key, value1,value2 -> value1+value2)
  end

  defp sum_values_per_user(
         [id, food_name, price],
         %{"foods" => foods, "users" => users} = report
       ) do
    users = Map.put(users, id, users[id] + price)
    foods = Map.put(foods, food_name, foods[food_name] + 1)

    %{report | "users" => users, "foods" => foods}
  end
end
