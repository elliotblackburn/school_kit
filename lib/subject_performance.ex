defmodule SchoolKit.SubjectPerformance do
  alias SchoolKit.Attainment8.NationalEstimates
  alias SchoolKit.StudentRecord

  def generate_report(csv_path, cohort_year) do
    csv_path
    |> SchoolKit.Parser.from_csv()
    |> reject_no_ks2()
    # Progress 8 for each subject, for each student record
    |> Enum.reduce(%{}, fn %StudentRecord{subject_results: subject_results} = student_record,
                           agg_subject_results ->
      subject_results
      |> reject_invalid_subjects()
      |> Enum.reduce(agg_subject_results, fn {subject_key, grade}, acc ->
        add_to_subject_report(acc, subject_key, student_record, grade, cohort_year)
      end)
    end)
    |> Enum.map(&calculate_subject_report/1)
  end

  defp reject_no_ks2(student_record) do
    # Progress 8 calculations require KS2 results, so we remove any
    # student who did not have them when doing subject analysis.
    Enum.reject(student_record, &(Map.get(&1, :ks2) == nil))
  end

  defp reject_invalid_subjects(student_record) do
    # English Lit + Lang "Open" subjects are generated internally to help with
    # progress 8 buckets. They shouldn't be considered as independent subjects
    # for analysing subject performance.
    student_record
    |> Enum.reject(fn {subject_key, _grade} ->
      subject_key in [:english_language_open, :english_literature_open]
    end)
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

  defp add_to_subject_report(
         report,
         subject_key,
         %StudentRecord{
           ks2: ks2,
           school: school,
           gender: gender,
           disadvantaged: disadvantaged,
           SEND: send
         } = _student_record,
         grade,
         cohort_year
       ) do
    national_estimates =
      NationalEstimates.get_national_estimates(
        cohort_year,
        ks2.average_score
      )

    {subject_key, progress} = progress_8_for_subject(subject_key, grade, national_estimates)

    student_subject_stats = %{
      attainment: grade,
      progress: progress,
      attributes: %{
        school: school,
        gender: gender,
        disadvantaged: disadvantaged,
        send: send
      }
    }

    if Map.has_key?(report, subject_key) do
      Map.update!(report, subject_key, &(&1 ++ [student_subject_stats]))
    else
      Map.put(report, subject_key, [student_subject_stats])
    end
  end

  defp calculate_subject_report({subject_key, stat_records}) do
    {total_attainment_average, total_progress_average} =
      attribute_averages(stat_records, fn _ -> true end)

    {male_attainment_average, male_progress_average} =
      attribute_averages(stat_records, fn record -> record.attributes.gender == :male end)

    {female_attainment_average, female_progress_average} =
      attribute_averages(stat_records, fn record -> record.attributes.gender == :female end)

    {disadvantaged_attainment_average, disadvantaged_progress_average} =
      attribute_averages(stat_records, fn record -> record.attributes.disadvantaged == true end)

    {send_attainment_average, send_progress_average} =
      attribute_averages(stat_records, fn record -> record.attributes.send != nil end)

    %{
      "Subject" => subject_atom_to_str(subject_key),
      "Attainment Avg" => total_attainment_average,
      "Progress Avg" => total_progress_average,
      "Male Attainment Avg" => male_attainment_average,
      "Male Progress Avg" => male_progress_average,
      "Female Attainment Avg" => female_attainment_average,
      "Female Progress Avg" => female_progress_average,
      "Disadvantaged Attainment Avg" => disadvantaged_attainment_average,
      "Disadvantaged Progress Avg" => disadvantaged_progress_average,
      "SEND Attainment Avg" => send_attainment_average,
      "SEND Progress Avg" => send_progress_average
    }
  end

  defp attribute_averages(records, test_fn) do
    filtered_records = Enum.filter(records, test_fn)

    if Enum.empty?(filtered_records) do
      {nil, nil}
    else
      attainment_average =
        filtered_records
        |> average(:attainment)
        |> Float.round(2)

      progress_average =
        filtered_records
        |> average(:progress)
        |> Float.round(2)

      {attainment_average, progress_average}
    end
  end

  defp average(collection, key) do
    sum =
      collection
      |> Enum.map(&Map.get(&1, key))
      |> Enum.sum()

    sum / length(collection)
  end

  defp subject_atom_to_str(subject_atom) do
    subject_atom
    |> Atom.to_string()
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end
end
