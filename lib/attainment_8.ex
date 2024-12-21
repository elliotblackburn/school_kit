defmodule SchoolKit.Attainment8 do
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
      get_top_three_subjects(subject_results, bucket_2_subjects())

    bucket_2_result = %{
      subject_1: subject_1,
      subject_2: subject_2,
      subject_3: subject_3,
      total: sum_bucket_grades(subject_1[:grade], subject_2[:grade], subject_3[:grade])
    }

    Map.put(attainment_8, :bucket_2, bucket_2_result)
  end

  def calculate_bucket_3(attainment_8, subject_results) do
    # The un-used English subject can be included in Bucket 3
    remaining_english_subject =
      case attainment_8 do
        %{bucket_1: %{subject_key: :english_literature}} ->
          :english_language

        _ ->
          :english_literature
      end

    # Anything which was not used in Bucket 2, can also be included in Bucket 3
    remaining_bucket_2_subjects =
      bucket_2_subjects()
      |> Enum.filter(fn subject ->
        !Enum.any?(1..3, fn i ->
          subject == attainment_8[:bucket_2][:"subject_#{i}"][:subject_key]
        end)
      end)

    # Create full, personalised list, of bucket 3 subjects for the student
    available_bucket_3_subjects =
      bucket_3_subjects() ++
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

  def bucket_1_subjects() do
    [
      :english_language,
      :english_literature,
      :maths
    ]
  end

  def bucket_2_subjects() do
    [
      :science_double_award_1,
      :science_double_award_2,
      :science_biology,
      :science_chemistry,
      :science_physics,
      :ict_computing,
      :geography,
      :history,
      :mfl_french,
      :mfl_german,
      :mfl_spanish,
      :mfl_chinese,
      :mfl_other
    ]
  end

  def bucket_3_subjects() do
    [
      :art,
      :business_studies,
      :design_and_technology,
      :drama,
      :food_prep_and_nutrition,
      :media_studies,
      :music,
      :photography,
      :physical_education,
      :religious_studies,
      :textiles,
      :gcse_other,
      :open_subject_13,
      :open_subject_14,
      :open_subject_15,
      :music_vocational,
      :music_tech_vocational,
      :performing_arts_vocational,
      :sport_vocational,
      :travel_tourism_vocational,
      :child_development_vocational,
      :engineering_vocational,
      :health_and_social_care_vocational,
      :it_i_media_vocational,
      :wjec_vocational_2,
      :wjec_vocational_3,
      :ncfe_vocational_1,
      :ncfe_vocational_2

      # "L2 Non-Counting Qual - AQA L2 Further Maths Cert",
      # "L2 Non-Counting Qual - Subject 2",
      # "L1/2 (Fdn/High) Project",
      # "L1/2 Non-Counting Qual- Subject 1",
      # "L1/2 Non-Counting Qual- Subject 2",
      # "L1 Non-Counting Qual - Subject 1",
      # "L1 Non-Counting Qual - Subject 2",
      # "Entry Level Cert - Subject 1",
      # "Entry Level Cert - Subject 2",
      # "Entry Level Cert - Subject 3",
    ]
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
