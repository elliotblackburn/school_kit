defmodule SchoolKit.Parser.StudentRecordParser do
  def parse_student_record(record) do
    # TODO: Improve input column names
    %{
      name: record["Surname Forename"],
      school: record["School"],
      gender: parse_gender(record["Gender  (M/F)"]),
      pupil_premium: parse_boolean(record["Pupil Premium  (Y/N)"]),
      disadvantaged: parse_boolean(record["Disadvantaged -
FSM / FSM6 / LAC (Y/N)"]),
      SEND: parse_SEND(record["SEND  (E / K / N)"]),
      attendance_band: parse_ks2_results(record["Attendance Band"]),
      ks2:
        parse_ks2_results(
          record["KS2 Reading Scaled Score"],
          record["KS2 Maths Scaled Score"]
        )
    }
  end

  defp parse_gender(""), do: nil
  defp parse_gender("M"), do: :male
  defp parse_gender("F"), do: :female

  defp parse_boolean(""), do: nil
  defp parse_boolean("Y"), do: true
  defp parse_boolean("N"), do: false

  defp parse_SEND(""), do: nil
  defp parse_SEND("E"), do: :ehcp
  defp parse_SEND("K"), do: :arranged_support
  defp parse_SEND("N"), do: :none

  defp parse_ks2_results(band) do
    Map.fetch!(
      %{
        "" => "-50%",
        "50%-" => "-50%",
        "50-%" => "-50%",
        "50-79%" => "50-79%",
        "80-89%" => "80-89%",
        "90-95%" => "90-95%",
        "90-96%" => "90-95%",
        "96%+" => "96%+"
      },
      band
    )
  end

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
