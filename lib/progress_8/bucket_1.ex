defmodule SchoolKit.Progress8.Bucket1 do
  def calculate(progress_8, bucket_attainment, a8_national_estimates, all_subject_results) do
    english_subject_key = bucket_attainment.english.subject_key

    english_grade = bucket_attainment.english.grade || 0

    english_progress_8 =
      english_progress_8_calculator(
        a8_national_estimates,
        english_grade,
        all_subject_results
      )

    maths_grade = bucket_attainment.maths.grade || 0

    maths_progress_8 =
      maths_progress_8_calculator(a8_national_estimates, maths_grade)

    bucket_1_result = %{
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
      progress_8: maths_progress_8 + english_progress_8
    }

    Map.put(progress_8, :bucket_1, bucket_1_result)
  end

  defp english_progress_8_calculator(a8_national_estimates, grade, all_subject_results) do
    # English is only double-weighted if the student sat both exams,
    # a U (0) grade is acceptable in this situation but they must have
    # actually sat the exams, so `nil` grades are not acceptable.
    multiplier =
      case all_subject_results do
        %{english_literature: nil} ->
          1.0

        %{english_language: nil} ->
          1.0

        _ ->
          2.0
      end

    estimate = a8_national_estimates.a8_english_estimate / 2.0
    (grade - estimate) * multiplier
  end

  defp maths_progress_8_calculator(a8_national_estimates, grade) do
    estimate = a8_national_estimates.a8_maths_estimate / 2.0
    (grade - estimate) * 2.0
  end
end
