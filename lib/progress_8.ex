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

  def calculate_progress_8(student_record, a8_national_estimates) do
    bucket_1 =
      calculate_progress_8_bucket_1(
        student_record.attainment_8.bucket_1,
        a8_national_estimates
      )

    bucket_2 =
      calculate_progress_8_bucket_2(
        student_record.attainment_8.bucket_2,
        a8_national_estimates
      )

    bucket_3 =
      calculate_progress_8_bucket_3(
        student_record.attainment_8.bucket_3,
        a8_national_estimates
      )

    %{
      bucket_1: bucket_1,
      bucket_2: bucket_2,
      bucket_3: bucket_3,
      total: %{
        total_score: student_record.attainment_8.total.total_score,
        average_score: student_record.attainment_8.total.average_score,
        progress_8: bucket_1.progress_8 + bucket_2.progress_8 + bucket_3.progress_8
      }
    }
  end

  defp calculate_progress_8_bucket_1(
         bucket_attainment,
         a8_national_estimates
       ) do
    english_subject_key = bucket_attainment.english.subject_key

    english_grade = bucket_attainment.english.grade || 0

    english_progress_8 =
      english_progress_8_calculator(a8_national_estimates, english_grade)

    maths_grade = bucket_attainment.maths.grade || 0

    maths_progress_8 =
      maths_progress_8_calculator(a8_national_estimates, maths_grade)

    %{
      maths: %{
        subject_key: :maths,
        grade: bucket_attainment.maths.grade,
        progress_8: maths_progress_8
      },
      english: %{
        subject_key: english_subject_key,
        grade: bucket_attainment.english.grade,
        progress_8: english_progress_8
      },
      total: bucket_attainment.total,
      # Bucket 1 subjects are double weighted. We do this for the final calculation
      # rather than on the subjects themselves for clarity.
      progress_8: (maths_progress_8 + english_progress_8) * 2.0
    }
  end

  defp calculate_progress_8_bucket_2(
         bucket_attainment,
         a8_national_estimates
       ) do
    calculate_progress_8_for_three_subject_bucket(
      bucket_attainment,
      fn subject_grade ->
        ebacc_progress_8_calculator(a8_national_estimates, subject_grade)
      end
    )
  end

  defp calculate_progress_8_bucket_3(
         bucket_attainment,
         a8_national_estimates
       ) do
    calculate_progress_8_for_three_subject_bucket(
      bucket_attainment,
      fn subject_grade ->
        open_progress_8_calculator(a8_national_estimates, subject_grade)
      end
    )
  end

  defp calculate_progress_8_for_three_subject_bucket(
         bucket_attainment,
         progress_calculator_fn
       ) do
    # TODO: Handle edge case where English Lit or English Lang are picked
    # for a bucket 3 subject. In this case we will need to re-calculate the progress 8,
    # and use the Open subject formula where we divide by 3 rather than 2.
    subject_1_grade = bucket_attainment.subject_1.grade

    subject_1 = %{
      subject_key: bucket_attainment.subject_1.subject_key,
      grade: bucket_attainment.subject_1.grade,
      progress_8: progress_calculator_fn.(subject_1_grade)
    }

    subject_2_grade = bucket_attainment.subject_2.grade

    subject_2 = %{
      subject_key: bucket_attainment.subject_2.subject_key,
      grade: bucket_attainment.subject_2.grade,
      progress_8: progress_calculator_fn.(subject_2_grade)
    }

    subject_3_grade = bucket_attainment.subject_3.grade

    subject_3 = %{
      subject_key: bucket_attainment.subject_3.subject_key,
      grade: bucket_attainment.subject_3.grade,
      progress_8: progress_calculator_fn.(subject_3_grade)
    }

    %{
      subject_1: subject_1,
      subject_2: subject_2,
      subject_3: subject_3,
      total: bucket_attainment.total,
      progress_8: subject_1.progress_8 + subject_2.progress_8 + subject_3.progress_8
    }
  end

  defp english_progress_8_calculator(a8_national_estimates, subject_grade) do
    # This is true when the subject is included in Bucket 1, but if it's included in Bucket 3
    # then the divisor is 3.0 because it's classified as an Open subject in this case.
    subject_grade - a8_national_estimates.a8_english_estimate / 2.0
  end

  defp maths_progress_8_calculator(a8_national_estimates, subject_grade) do
    subject_grade - a8_national_estimates.a8_maths_estimate / 2.0
  end

  defp ebacc_progress_8_calculator(a8_national_estimates, subject_grade) do
    subject_grade - a8_national_estimates.a8_EBacc_estimate / 3.0
  end

  defp open_progress_8_calculator(a8_national_estimates, subject_grade) do
    subject_grade - a8_national_estimates.a8_open_estimate / 3.0
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
