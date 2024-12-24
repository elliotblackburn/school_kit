defmodule SchoolKit.Attainment8 do
  @moduledoc """
  A students Attainment 8 shows what they managed to achieve in their final GCSE exam results. It is based exclusively on their exam results.

  The attainment 8 isn't all that useful by itself, but it feeds into the Progress 8 score which we will calculate after. Attainment 8 is also not something students will think about for themselves, but it helps us to compare cohorts of students, and understands a schools performance.

  Attainment 8 is calculated via a series of weighted buckets. Particular subjects fit into different buckets, and some buckets are weighted higher. This calculation and the subject bucket assignments are dictated by the DfE.

  ### Bucket 1 - English and Maths

  This is for English and Maths, and the end result is double weighted. Bucket 1 is calculated by taking the best grade between English Literature and English Language, and adding it to the grade for Maths. For example, a student with English Literature of 4, English Language of 5, and Maths of 4 will get a final Bucket 1 grade of 18. The English Language grade was higher, so that was doubled and added to Maths which was also doubled.

  The unused English grade can be re-used in Bucket 3 later on.

  ### Bucket 2 - English Baccalaureate (EBacc)

  Sciences, Computing, Geography, History, and Modern Foreign Languages make up the majority of the English Baccalaureate which is Bucket 2. The top 3 grades from across these subjects are selected, and added together to create the Bucket 2 result. This bucket is single weighted.

  ### Bucket 3 - Open Subjects (Vocationals)

  Vocational qualifications such as BTEC's and anything else fall into Bucket 3. The unused English subject from Bucket 1 is also included here. Like Bucket 2, we take the top three grades and add them together to get the final Bucket 3 result. This bucket is also single weighted.

  ### Total Attainment 8

  The total attainment 8 is simply calculated by adding together the total value from all three buckets. We also calculate a 10 subject average which is used in other calculations later on.
  """

  alias SchoolKit.Subjects

  def calculate_attainment_8(%{subject_results: subject_results} = student_record) do
    attainment_8 =
      %{}
      |> calculate_bucket_1(subject_results)
      |> calculate_bucket_2(subject_results)
      |> calculate_bucket_3(subject_results)
      |> calculate_total()

    Map.put(student_record, :attainment_8, attainment_8)
  end

  def calculate_bucket_1(attainment_8, subject_results) do
    english = get_higher_grade(subject_results, :english_literature, :english_language)

    bucket_1_result = %{
      english: english,
      maths: %{subject_key: :maths, grade: subject_results[:maths]},
      total: sum_bucket_grades(subject_results[:maths], english[:grade], nil, 2.0)
    }

    Map.put(attainment_8, :bucket_1, bucket_1_result)
  end

  def calculate_bucket_2(attainment_8, subject_results) do
    {subject_1, subject_2, subject_3} =
      get_top_three_subjects(subject_results, Subjects.bucket_2_subjects())

    bucket_2_result = %{
      subject_1: subject_1,
      subject_2: subject_2,
      subject_3: subject_3,
      total: sum_bucket_grades(subject_1[:grade], subject_2[:grade], subject_3[:grade])
    }

    Map.put(attainment_8, :bucket_2, bucket_2_result)
  end

  def calculate_bucket_3(attainment_8, subject_results) do
    # The un-used English subject can be included in Bucket 3. We need to include
    # the "open" version as this has a different Progress 8 weighting to the standard
    # bucket 1 version.
    remaining_english_subject =
      case attainment_8 do
        %{bucket_1: %{english: %{subject_key: :english_literature}}} ->
          :english_language_open

        _ ->
          :english_literature_open
      end

    # Anything which was not used in Bucket 2, can also be included in Bucket 3
    remaining_bucket_2_subjects =
      Subjects.bucket_2_subjects()
      |> Enum.filter(fn subject ->
        !Enum.any?(1..3, fn i ->
          subject == attainment_8[:bucket_2][:"subject_#{i}"][:subject_key]
        end)
      end)

    # Create full, personalised list, of bucket 3 subjects for the student
    available_bucket_3_subjects =
      Subjects.bucket_3_subjects() ++
        [remaining_english_subject] ++
        remaining_bucket_2_subjects

    {subject_1, subject_2, subject_3} =
      get_top_three_subjects(subject_results, available_bucket_3_subjects)

    bucket_3_result = %{
      subject_1: subject_1,
      subject_2: subject_2,
      subject_3: subject_3,
      total: sum_bucket_grades(subject_1[:grade], subject_2[:grade], subject_3[:grade])
    }

    Map.put(attainment_8, :bucket_3, bucket_3_result)
  end

  def calculate_total(attainment_8) do
    bucket_1_total = attainment_8[:bucket_1][:total]
    bucket_2_total = attainment_8[:bucket_2][:total]
    bucket_3_total = attainment_8[:bucket_3][:total]
    total = bucket_1_total + bucket_2_total + bucket_3_total

    attainment_8_total = %{
      total_score: bucket_1_total + bucket_2_total + bucket_3_total,
      # This is fixed at 10 for all students as per DfE formulas
      average_score: total / 10.0
    }

    Map.put(attainment_8, :total, attainment_8_total)
  end

  defp sum_bucket_grades(subject_1_grade, subject_2_grade, subject_3_grade, weight \\ 1) do
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

  defp filter_subjects(all_subjects, allowed_subjects),
    do: Enum.filter(all_subjects, fn {key, _value} -> key in allowed_subjects end)

  defp create_subject_grade_map({subject_key, subject_grade}) do
    %{
      subject_key: subject_key,
      grade: subject_grade
    }
  end

  defp sort_subject_grade_list(subject_grade_list),
    do: Enum.sort(subject_grade_list, &(&1[:grade] >= &2[:grade]))

  defp get_top_three_subjects(student_record, available_subjects) do
    sorted_grades =
      student_record
      |> Map.to_list()
      |> filter_subjects(available_subjects)
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

  defp get_higher_grade(row, subject_1, subject_2) do
    subject_1_grade = row[subject_1]
    subject_2_grade = row[subject_2]

    if subject_1_grade >= subject_2_grade do
      %{subject_key: subject_1, grade: subject_1_grade}
    else
      %{subject_key: subject_2, grade: subject_2_grade}
    end
  end
end
