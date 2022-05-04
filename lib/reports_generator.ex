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

  def fetch_higher_cost(report, option) when option in @options,
    do: {:ok, Enum.max_by(report[option], fn {_key, value} -> value end)}

  def fetch_higher_cost(_report, _option), do: {:error, "Invalid option!"}

  defp reports_acc do
    foods = Enum.into(@available_foods, %{}, &{&1, 0})
    users = Enum.into(1..30, %{}, &{Integer.to_string(&1), 0})

    %{"users" => users, "foods" => foods}
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
