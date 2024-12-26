defmodule SchoolKit.Attainment8.Bucket2 do
  @moduledoc """
  Bucket 2 are the English Baccalaureate subjects. The top 3 grades from
  across these subjects are selected, and added together to create the
  Bucket 2 result. This bucket is single weighted.
  """

  alias SchoolKit.Subjects
  alias SchoolKit.Attainment8.Utils

  def calculate(attainment_8, subject_results) do
    {subject_1, subject_2, subject_3} =
      Utils.get_top_three_subjects(
        subject_results,
        Subjects.bucket_2_subjects()
      )

    bucket_2_result = %{
      subject_1: subject_1,
      subject_2: subject_2,
      subject_3: subject_3,
      total:
        Utils.sum_bucket_grades(
          subject_1[:grade],
          subject_2[:grade],
          subject_3[:grade]
        )
    }

    Map.put(attainment_8, :bucket_2, bucket_2_result)
  end
end
