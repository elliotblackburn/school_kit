defmodule SchoolKit.Progress8 do
  @moduledoc """
  A students Progress 8 is a representation of how much progress a student made between KS2 and the end of KS3. It is calculated using a lookup data set published by the DfE for each cohort after they've taken their final GCSE exams. This data set defines an expected progress of a student in a subject given a particular KS2 result.

  Progress 8 is not something which students themselves ever receive or think about. It is purely to help assess the performance of a school.

  Like with Attainment 8, the Progress 8 calculations are given by the DfE.

  ## Implementation notes:

  * English P8 = Actual grade - (English estimate / 2)
  * Maths P8 = Actual grade - (Maths estimate / 2)
  * Each EBacc P8 = Actual grade - (EBacc estimate / 3)
  * Each Open P8 = Actual grade - (Open estimate / 3)

  Each bucket total is the sum of each included subjects P8.
  """

  alias SchoolKit.Attainment8.NationalEstimates
  alias SchoolKit.Progress8.Bucket1
  alias SchoolKit.Progress8.Bucket2
  alias SchoolKit.Progress8.Bucket3
  alias SchoolKit.Attainment8.StudentRecord

  def calculate_progress_8(%StudentRecord{ks2: ks2} = student_record, _cohort_year) when is_nil(ks2),
    do: Map.put(student_record, :progress_8, nil)

  def calculate_progress_8(%StudentRecord{} = student_record, cohort_year) do
    student_attainment_estimates =
      NationalEstimates.get_national_estimates(cohort_year, student_record.ks2.average_score)

    progress_8 =
      %{}
      |> Bucket1.calculate(
        student_record.attainment_8.bucket_1,
        student_attainment_estimates,
        student_record.subject_results
      )
      |> Bucket2.calculate(
        student_record.attainment_8.bucket_2,
        student_attainment_estimates
      )
      |> Bucket3.calculate(
        student_record.attainment_8.bucket_3,
        student_attainment_estimates
      )
      |> calculate_total(student_record)

    Map.put(student_record, :progress_8, progress_8)
  end

  def calculate_total(progress_8, %StudentRecord{attainment_8: attainment_8} = _student_record) do
    total = %{
      total_score: attainment_8.total.total_score,
      average_score: attainment_8.total.average_score,
      progress_8:
        progress_8.bucket_1.progress_8 +
          progress_8.bucket_2.progress_8 +
          progress_8.bucket_3.progress_8
    }

    Map.put(progress_8, :total, total)
  end

  def load_national_estimates(path) do
    path
    |> File.stream!()
    |> CSV.decode(headers: true)
    |> Enum.map(fn {:ok, i} ->
      {ks2_average_level, _} = Float.parse(i["Key stage 2 fine level"])
      {a8_estimate, _} = Float.parse(i["Attainment 8 estimate"])
      {a8_english_estimate, _} = Float.parse(i["A8 Nat Est - English"])
      {a8_maths_estimate, _} = Float.parse(i["A8 Nat Est - Maths"])
      {a8_EBacc_estimate, _} = Float.parse(i["A8 Nat Est - EBacc"])
      {a8_open_estimate, _} = Float.parse(i["A8 Nat Est - Open"])
      {average_EBacc_slots_filled, _} = Float.parse(i["Average EBacc slots filled (out of 3)"])
      {average_open_slots_filled, _} = Float.parse(i["Average open slots filled (out of 3)"])

      %{
        ks2_average_level: ks2_average_level,
        a8_estimate: a8_estimate,
        a8_english_estimate: a8_english_estimate,
        a8_maths_estimate: a8_maths_estimate,
        a8_EBacc_estimate: a8_EBacc_estimate,
        a8_open_estimate: a8_open_estimate,
        average_EBacc_slots_filled: average_EBacc_slots_filled,
        average_open_slots_filled: average_open_slots_filled
      }
    end)
  end
end
