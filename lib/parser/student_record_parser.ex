defmodule SchoolKit.Parser.StudentRecordParser do
  alias SchoolKit.Attainment8.StudentRecord

  def parse_student_record(record) do
    %StudentRecord{
      name: record["Surname Forename"],
      school: record["School"],
      gender: parse_gender(record["Gender"]),
      pupil_premium: parse_boolean(record["Pupil Premium"]),
      disadvantaged: parse_boolean(record["Disadvantaged"]),
      SEND: parse_SEND(record["SEND"]),
      attendance_band: parse_attendance_band(record["Attendance Band"]),
      ks2:
        parse_ks2_results(
          record["KS2 Reading Scaled Score"],
          record["KS2 Maths Scaled Score"]
        )
    }
  end

  defp parse_gender(input) when is_binary(input) do
    case input do
      "M" -> :male
      "m" -> :male
      "male" -> :male
      "F" -> :female
      "f" -> :female
      "female" -> :female
      _ -> nil
    end
  end

  defp parse_gender(_input), do: nil

  defp parse_boolean(input) when is_binary(input) do
    case input do
      "Y" -> true
      "y" -> true
      "yes" -> true
      "true" -> true
      "T" -> true
      "t" -> true
      "N" -> false
      "n" -> false
      "no" -> false
      "false" -> false
      "F" -> false
      "f" -> false
      _ -> nil
    end
  end

  defp parse_boolean(_input), do: nil

  defp parse_SEND(input) when is_binary(input) do
    case String.upcase(input) do
      "E" -> :ehcp
      "EHCP" -> :ehcp
      "K" -> :arranged_support
      "ARRANGED SUPPORT" -> :arranged_support
      "N" -> :none
      "NONE" -> :none
      _ -> nil
    end
  end

  defp parse_SEND(_input), do: nil

  defp parse_attendance_band(band) when is_binary(band) do
    band = String.trim(band, "-")

    band_result =
      Map.fetch(
        %{
          "" => "-50%",
          # Handle bad data entry found in real data
          "50%-" => "-50%",
          # Handle bad data entry found in real data
          "50-%" => "-50%",
          "50-79%" => "50-79%",
          "80-89%" => "80-89%",
          "90-95%" => "90-95%",
          # Handle bad data entry found in real data
          "90-96%" => "90-95%",
          "96%+" => "96%+"
        },
        band
      )

    case band_result do
      {:ok, result} -> result
      :error -> nil
    end
  end

  defp parse_attendance_band(_band), do: nil

  defp parse_ks2_results(reading_score, maths_score)
       when reading_score == "" or maths_score == "",
       do: nil

  defp parse_ks2_results(reading_score, maths_score)
       when is_nil(reading_score) or is_nil(maths_score),
       do: nil

  defp parse_ks2_results(reading_score, maths_score) do
    reading_score_float =
      case Float.parse(reading_score) do
        {float, _} -> float
        :error -> nil
      end

    maths_score_float =
      case Float.parse(maths_score) do
        {float, _} -> float
        :error -> nil
      end

    if reading_score_float != nil and maths_score_float != nil do
      %{
        reading_score: reading_score_float,
        maths_score: maths_score_float,
        average_score: (reading_score_float + maths_score_float) / 2.0
      }
    else
      nil
    end
  end
end
