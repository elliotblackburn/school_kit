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

  def calculate_progress_8_per_subject(student_record, a8_estimates) do
    subject_progress_map = subject_progress_calculator_map()

    student_record[:subject_results]
    |> Enum.map(fn {subject_key, grade} ->
      {_subject_key, calculator_fn} =
        Enum.find(subject_progress_map, fn {prog_subject_key, _calculator_fn} ->
          prog_subject_key == subject_key
        end)

      subject_result = %{
        grade: grade,
        progress_8: calculator_fn.(a8_estimates, grade)
      }

      {subject_key, subject_result}
    end)
    |> Map.new()
  end

  defp english_progress_8_calculator(a8_national_estimates, subject_grade) do
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

  defp subject_progress_calculator_map() do
    [
      {:english_language, &english_progress_8_calculator/2},
      {:english_literature, &english_progress_8_calculator/2},
      {:maths, &maths_progress_8_calculator/2},
      {:science_biology, &ebacc_progress_8_calculator/2},
      {:science_chemistry, &ebacc_progress_8_calculator/2},
      {:science_physics, &ebacc_progress_8_calculator/2},
      {:ict_computing, &ebacc_progress_8_calculator/2},
      {:geography, &ebacc_progress_8_calculator/2},
      {:history, &ebacc_progress_8_calculator/2},
      {:mfl_french, &ebacc_progress_8_calculator/2},
      {:mfl_german, &ebacc_progress_8_calculator/2},
      {:mfl_spanish, &ebacc_progress_8_calculator/2},
      {:mfl_chinese, &ebacc_progress_8_calculator/2},
      {:mfl_other, &ebacc_progress_8_calculator/2},
      {:science_double_award_1, &ebacc_progress_8_calculator/2},
      {:science_double_award_2, &ebacc_progress_8_calculator/2},
      {:art, &open_progress_8_calculator/2},
      {:business_studies, &open_progress_8_calculator/2},
      {:design_and_technology, &open_progress_8_calculator/2},
      {:drama, &open_progress_8_calculator/2},
      {:food_prep_and_nutrition, &open_progress_8_calculator/2},
      {:media_studies, &open_progress_8_calculator/2},
      {:music, &open_progress_8_calculator/2},
      {:photography, &open_progress_8_calculator/2},
      {:physical_education, &open_progress_8_calculator/2},
      {:religious_studies, &open_progress_8_calculator/2},
      {:textiles, &open_progress_8_calculator/2},
      {:gcse_other, &open_progress_8_calculator/2},
      {:open_subject_13, &open_progress_8_calculator/2},
      {:open_subject_14, &open_progress_8_calculator/2},
      {:open_subject_15, &open_progress_8_calculator/2},
      {:music_vocational, &open_progress_8_calculator/2},
      {:music_tech_vocational, &open_progress_8_calculator/2},
      {:performing_arts_vocational, &open_progress_8_calculator/2},
      {:sport_vocational, &open_progress_8_calculator/2},
      {:travel_tourism_vocational, &open_progress_8_calculator/2},
      {:child_development_vocational, &open_progress_8_calculator/2},
      {:engineering_vocational, &open_progress_8_calculator/2},
      {:health_and_social_care_vocational, &open_progress_8_calculator/2},
      {:it_i_media_vocational, &open_progress_8_calculator/2},
      {:wjec_vocational_2, &open_progress_8_calculator/2},
      {:wjec_vocational_3, &open_progress_8_calculator/2},
      {:ncfe_vocational_1, &open_progress_8_calculator/2},
      {:ncfe_vocational_2, &open_progress_8_calculator/2}
    ]
  end

  def calculate_progress_8(student_record, subjects_progress_8, a8_national_estimates) do
    bucket_1 =
      calculate_progress_8_bucket_1(
        student_record.attainment_8.bucket_1,
        subjects_progress_8,
        a8_national_estimates
      )

    bucket_2 =
      calculate_progress_8_bucket_2(
        student_record.attainment_8.bucket_2,
        subjects_progress_8,
        a8_national_estimates
      )

    bucket_3 =
      calculate_progress_8_bucket_3(
        student_record.attainment_8.bucket_3,
        subjects_progress_8,
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
         subjects_progress_8,
         a8_national_estimates
       ) do
    english_subject_key = bucket_attainment.english.subject_key
    english_progress_8_default = english_progress_8_calculator(a8_national_estimates, 0)

    english_progress_8 =
      get_subject_progress_8(
        english_subject_key,
        subjects_progress_8,
        english_progress_8_default
      )

    maths_progress_8_default = maths_progress_8_calculator(a8_national_estimates, 0)

    maths_progress_8 =
      get_subject_progress_8(
        :maths,
        subjects_progress_8,
        maths_progress_8_default
      )

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
         subjects_progress_8,
         a8_national_estimates
       ) do
    calculate_progress_8_for_three_subject_bucket(
      bucket_attainment,
      subjects_progress_8,
      ebacc_progress_8_calculator(a8_national_estimates, 0)
    )
  end

  defp calculate_progress_8_bucket_3(
         bucket_attainment,
         subjects_progress_8,
         a8_national_estimates
       ) do
    calculate_progress_8_for_three_subject_bucket(
      bucket_attainment,
      subjects_progress_8,
      open_progress_8_calculator(a8_national_estimates, 0)
    )
  end

  defp calculate_progress_8_for_three_subject_bucket(
         bucket_attainment,
         subjects_progress_8,
         default_progress
       ) do
    subject_1 = %{
      subject_key: bucket_attainment.subject_1.subject_key,
      grade: bucket_attainment.subject_1.grade,
      progress_8:
        get_subject_progress_8(
          bucket_attainment.subject_1.subject_key,
          subjects_progress_8,
          default_progress
        )
    }

    subject_2 = %{
      subject_key: bucket_attainment.subject_2.subject_key,
      grade: bucket_attainment.subject_2.grade,
      progress_8:
        get_subject_progress_8(
          bucket_attainment.subject_2.subject_key,
          subjects_progress_8,
          default_progress
        )
    }

    subject_3 = %{
      subject_key: bucket_attainment.subject_3.subject_key,
      grade: bucket_attainment.subject_3.grade,
      progress_8:
        get_subject_progress_8(
          bucket_attainment.subject_3.subject_key,
          subjects_progress_8,
          default_progress
        )
    }

    %{
      subject_1: subject_1,
      subject_2: subject_2,
      subject_3: subject_3,
      total: bucket_attainment.total,
      progress_8: subject_1.progress_8 + subject_2.progress_8 + subject_3.progress_8
    }
  end

  defp get_subject_progress_8(subject_key, subjects_progress_8, default) do
    case subjects_progress_8[subject_key] do
      %{progress_8: progress_8} -> progress_8
      nil -> default
    end
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
