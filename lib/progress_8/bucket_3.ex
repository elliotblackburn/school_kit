defmodule SchoolKit.Progress8.Bucket3 do
  alias SchoolKit.Progress8.Utils

  defmodule Progress8Bucket3Result do
    defstruct [:subject_1, :subject_2, :subject_3, :total, :progress_8]
  end

  def calculate(progress_8, bucket_attainment, a8_national_estimates) do
    bucket_3_result =
      Utils.calculate_progress_8_for_three_subject_bucket(
        bucket_attainment,
        fn subject_grade ->
          open_progress_8_calculator(a8_national_estimates, subject_grade)
        end
      )

    %Progress8Bucket3Result{
      subject_1: bucket_3_result.subject_1,
      subject_2: bucket_3_result.subject_2,
      subject_3: bucket_3_result.subject_3,
      total: bucket_3_result.total,
      progress_8: bucket_3_result.progress_8
    }
    |> Map.put(progress_8, :bucket_3)
  end

  defp open_progress_8_calculator(a8_national_estimates, subject_grade) do
    subject_grade - a8_national_estimates.a8_open_estimate / 3.0
  end

  def calculate_single_subject(_subject, grade, a8_national_estimates) do
    open_progress_8_calculator(a8_national_estimates, grade)
  end
end
