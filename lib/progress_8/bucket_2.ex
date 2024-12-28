defmodule SchoolKit.Progress8.Bucket2 do
  alias SchoolKit.Progress8.Utils

  def calculate(progress_8, bucket_attainment, a8_national_estimates) do
    bucket_2_result =
      Utils.calculate_progress_8_for_three_subject_bucket(
        bucket_attainment,
        fn subject_grade ->
          ebacc_progress_8_calculator(a8_national_estimates, subject_grade)
        end
      )

    Map.put(progress_8, :bucket_2, bucket_2_result)
  end

  defp ebacc_progress_8_calculator(a8_national_estimates, subject_grade) do
    subject_grade - a8_national_estimates.a8_EBacc_estimate / 3.0
  end
end
