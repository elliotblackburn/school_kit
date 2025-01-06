defmodule SchoolKit.Progress8.Bucket1 do
  defmodule Progress8Bucket1Result do
    defstruct [:maths, :english, :total, :progress_8]
  end

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

    bucket_1_result = %Progress8Bucket1Result{
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

  @doc """
  Calculate the progress 8 value for a single subject in bucket 1, returning
  the unweighted progress value.

  This should be used when working with the subject result outside the context
  of progress 8 buckets. For example, when generating a report for a single subject.

  To calculate a students actual progress 8 score, use the `calculate` function.
  """
  def calculate_single_subject(subject_key, grade, estimates)
      when subject_key == :english_literature or subject_key == :english_language do
    estimate = estimates.a8_english_estimate / 2.0
    grade - estimate
  end

  def calculate_single_subject(:maths, grade, estimates) do
    estimate = estimates.a8_maths_estimate / 2.0
    grade - estimate
  end
end
