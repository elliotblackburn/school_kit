defmodule SchoolKit.Progress8.Utils do
  def calculate_progress_8_for_three_subject_bucket(
        bucket_attainment,
        progress_calculator_fn
      ) do
    subject_1_grade = bucket_attainment.subject_1.grade

    subject_1 = %{
      subject_key: bucket_attainment.subject_1.subject_key,
      grade: bucket_attainment.subject_1.grade,
      progress_8: progress_calculator_fn.(subject_1_grade)
    }

    subject_2_grade = bucket_attainment.subject_2.grade

    subject_2 = %{
      subject_key: bucket_attainment.subject_2.subject_key,
      grade: bucket_attainment.subject_2.grade,
      progress_8: progress_calculator_fn.(subject_2_grade)
    }

    subject_3_grade = bucket_attainment.subject_3.grade

    subject_3 = %{
      subject_key: bucket_attainment.subject_3.subject_key,
      grade: bucket_attainment.subject_3.grade,
      progress_8: progress_calculator_fn.(subject_3_grade)
    }

    %{
      subject_1: subject_1,
      subject_2: subject_2,
      subject_3: subject_3,
      total: bucket_attainment.total,
      progress_8: subject_1.progress_8 + subject_2.progress_8 + subject_3.progress_8
    }
  end
end
