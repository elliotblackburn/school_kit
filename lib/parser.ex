defmodule SchoolKit.Parser do
  alias SchoolKit.Parser.StudentRecordParser
  alias SchoolKit.Parser.GradeParser

  def from_csv(csv_path) do
    raw_results =
      csv_path
      |> File.stream!()
      |> CSV.decode(headers: true)
      |> Enum.map(fn {:ok, i} ->
        i
      end)

    raw_results
    |> Enum.map(fn raw_student_record ->
      # First, clean up the student record by pulling out everything we're interested in
      # which can just be mapped over without any changes needed.
      student_data = StudentRecordParser.parse_student_record(raw_student_record)

      # Now normalise all the grades into atom keys with float values. Drop any
      # subjects which the student didn't sit, or and break out double awards into
      # two entries.
      subject_results =
        raw_student_record
        |> Enum.map(fn {key, value} ->
          GradeParser.parse_grade(key, value)
        end)
        |> Enum.reduce(%{}, fn result, acc ->
          case result do
            :no_normaliser_found ->
              # subject not supported
              acc

            {_subject_key, nil} ->
              # student didn't sit single award subject
              acc

            [{_subject_1_key, nil}, {_subject_2_key, nil}] ->
              # student didn't sit double award subject
              acc

            {subject_key, grade} ->
              # single award
              Map.put(acc, subject_key, grade)

            [{subject_1_key, grade_1}, {subject_2_key, grade_2}] ->
              # double award
              acc
              |> Map.put(subject_1_key, grade_1)
              |> Map.put(subject_2_key, grade_2)
          end
        end)

      Map.put(student_data, :subject_results, subject_results)
    end)
  end
end
