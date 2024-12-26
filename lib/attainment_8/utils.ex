defmodule SchoolKit.Attainment8.Utils do
  @doc """
  Return the higher subject between the two provided subjects.
  """
  def get_higher_grade(row, subject_1, subject_2) do
    subject_1_grade = row[subject_1]
    subject_2_grade = row[subject_2]

    # Account for nil grades by assuming 0 for the comparison.
    # Otherwise nil grades would always be considered higher.
    if (subject_1_grade || 0) >= (subject_2_grade || 0) do
      %{subject_key: subject_1, grade: subject_1_grade}
    else
      %{subject_key: subject_2, grade: subject_2_grade}
    end
  end

  @doc """
  Sum the grades of three subjects and return the total. An
  optional weight can be provided to multiply the grades by.
  """
  def sum_bucket_grades(subject_1_grade, subject_2_grade, subject_3_grade, weight \\ 1) do
    subject_1_grade =
      if subject_1_grade != nil do
        subject_1_grade
      else
        0
      end

    subject_2_grade =
      if subject_2_grade != nil do
        subject_2_grade
      else
        0
      end

    subject_3_grade =
      if subject_3_grade != nil do
        subject_3_grade
      else
        0
      end

    subject_1_grade * weight + subject_2_grade * weight + subject_3_grade * weight
  end

  @doc """
  Return the students top three subjects by grade, based
  on the list of included subjects.
  """
  def get_top_three_subjects(student_record, included_subjects) do
    sorted_grades =
      student_record
      |> Map.to_list()
      |> filter_subjects(included_subjects)
      |> Enum.map(&create_subject_grade_map/1)
      |> sort_subject_grade_list()

    empty_grade = create_subject_grade_map({:empty, 0})

    case sorted_grades do
      [subject_1, subject_2, subject_3 | _] -> {subject_1, subject_2, subject_3}
      [subject_1, subject_2] -> {subject_1, subject_2, empty_grade}
      [subject_1] -> {subject_1, empty_grade, empty_grade}
      [] -> {empty_grade, empty_grade, empty_grade}
    end
  end

  defp filter_subjects(all_subjects, allowed_subjects),
    do: Enum.filter(all_subjects, fn {key, _value} -> key in allowed_subjects end)

  defp sort_subject_grade_list(subject_grade_list),
    do: Enum.sort(subject_grade_list, &(&1[:grade] >= &2[:grade]))

  defp create_subject_grade_map({subject_key, subject_grade}) do
    %{
      subject_key: subject_key,
      grade: subject_grade
    }
  end
end
