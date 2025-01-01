defmodule SchoolKit do
  alias SchoolKit.SubjectPerformance

  def generate_student_performance_results(csv_path, cohort_year) do
    csv_path
    |> SchoolKit.Parser.from_csv()
    |> Enum.map(fn student_record ->
      student_record
      |> SchoolKit.Attainment8.calculate_attainment_8()
      |> SchoolKit.Progress8.calculate_progress_8(cohort_year)
    end)
  end

  def generate_subject_progress_report_from_csv(csv_path, cohort_year) do
    SubjectPerformance.generate_report(csv_path, cohort_year)
  end
end
