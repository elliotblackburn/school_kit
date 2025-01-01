defmodule SchoolKit do
  alias SchoolKit.Attainment8.NationalEstimates

  def calculate_cohort_progress_from_csv(csv_path, cohort_year) do
    csv_path
    |> SchoolKit.Parser.from_csv()
    |> Enum.map(fn student_record ->
      student_record
      |> SchoolKit.Attainment8.calculate_attainment_8()
      |> SchoolKit.Progress8.calculate_progress_8(cohort_year)
    end)
  end

  def generate_subject_progress_report_from_csv(csv_path, cohort_year) do
    csv_path
    |> SchoolKit.Parser.from_csv()
    # Remove anyone without KS2 results, as those are required for Progress 8
    |> Enum.reject(&(Map.get(&1, :ks2) == nil))
    # Progress 8 for each subject, for each student record
    |> Enum.reduce(%{}, fn %{subject_results: subject_results, ks2: ks2}, agg_subject_results ->
      subject_results
      # Remove english "open" variant subjects as these are only used for bucket 3.
      |> Enum.reject(fn {subject_key, _grade} ->
        subject_key in [:english_language_open, :english_literature_open]
      end)
      |> Enum.reduce(agg_subject_results, fn {subject_key, grade}, acc ->
        national_estimates =
          NationalEstimates.get_national_estimates(
            cohort_year,
            ks2.average_score
          )

        {subject_key, progress} = progress_8_for_subject(subject_key, grade, national_estimates)

        if Map.has_key?(acc, subject_key) do
          Map.update!(acc, subject_key, &(&1 ++ [progress]))
        else
          Map.put(acc, subject_key, [progress])
        end
      end)
    end)
    |> Enum.map(fn {subject_key, progress_lst} ->
      subject_avg = Float.round(Enum.sum(progress_lst) / length(progress_lst), 2)
      {subject_key, subject_avg}
    end)
    |> Enum.into(%{})
  end

  defp progress_8_for_subject(subject, grade, national_estimates) do
    default_bucket =
      cond do
        subject in SchoolKit.Subjects.bucket_1_subjects() ->
          SchoolKit.Progress8.Bucket1

        subject in SchoolKit.Subjects.bucket_2_subjects() ->
          SchoolKit.Progress8.Bucket2

        subject in SchoolKit.Subjects.bucket_3_subjects() ->
          SchoolKit.Progress8.Bucket3
      end

    progress = default_bucket.calculate_single_subject(subject, grade, national_estimates)

    {subject, progress}
  end
end
