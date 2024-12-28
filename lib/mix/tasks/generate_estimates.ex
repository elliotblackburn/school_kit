defmodule Mix.Tasks.GenerateEstimates do
  @moduledoc """
  Generates a module for the national estimates from the DfE CSV file.

    $ mix generate_estimates
  """

  use Mix.Task

  def run([]) do
    # Read and transform the CSV data
    estimates = get_all_estimates()

    # Generate the Elixir code
    module_code = generate_module_code(estimates)

    # Write to a file in the `lib/attainment_8/` directory
    file_path = "lib/attainment_8/national_estimates.ex"
    File.mkdir_p!(Path.dirname(file_path))
    File.write!(file_path, module_code)

    Mix.shell().info("Module has been generated at #{file_path}")
  end

  defp get_all_estimates do
    # Get all files in priv/attainment_8_estimates
    root_path = Path.expand("priv/attainment_8_estimates")

    File.ls!(root_path)
    |> Enum.reduce(%{}, fn file_name, acc ->
      year = Path.basename(file_name, ".csv")

      estimate_data =
        "#{root_path}/#{file_name}"
        |> File.stream!()
        |> CSV.decode!(headers: true)
        |> Enum.map(&parse_row/1)

      Map.put(acc, year, estimate_data)
    end)
  end

  defp parse_row(row) do
    %{
      ks2_average_level: parse_float(row["Key stage 2 fine level"]),
      a8_estimate: parse_float(row["Attainment 8 estimate"]),
      a8_english_estimate: parse_float(row["A8 Nat Est - English"]),
      a8_maths_estimate: parse_float(row["A8 Nat Est - Maths"]),
      a8_EBacc_estimate: parse_float(row["A8 Nat Est - EBacc"]),
      a8_open_estimate: parse_float(row["A8 Nat Est - Open"]),
      average_EBacc_slots_filled: parse_float(row["Average EBacc slots filled (out of 3)"]),
      average_open_slots_filled: parse_float(row["Average open slots filled (out of 3)"])
    }
  end

  defp parse_float(value) do
    case Float.parse(value) do
      {float, _} -> float
      :error -> nil
    end
  end

  defp generate_module_code(estimates) do
    estimates_code = inspect(estimates, pretty: true, limit: :infinity)

    """
    defmodule SchoolKit.Attainment8.NationalEstimates do
      @moduledoc "All DfE national estimates for student Attainment based on KS2 result bands."

      @data #{estimates_code}

      @doc "Returns a map of national estimates for the given year."
      def get_national_estimates(year, ks2_average_score) do
        @data
        |> Map.get(year)
        |> Enum.find(&(&1.ks2_average_level == ks2_average_score))
      end
    end
    """
  end
end
