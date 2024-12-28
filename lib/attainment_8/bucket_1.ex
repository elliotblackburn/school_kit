defmodule SchoolKit.Attainment8.Bucket1 do
  @moduledoc """
  Bucket 1 is for English and Maths, and is the only double weighted
  bucket. The bucket takes the students best grade between English
  Literature and English Language, and adds it to the grade for Maths.
  The final result is then doubled.
  """

  alias SchoolKit.Attainment8.Utils

  def calculate(attainment_8, subject_results) do
    english = Utils.get_higher_grade(subject_results, :english_literature, :english_language)

    bucket_1_result = %{
      english: english,
      maths: %{subject_key: :maths, grade: subject_results[:maths]},
      total: Utils.sum_bucket_grades(subject_results[:maths], english[:grade], nil)
    }

    Map.put(attainment_8, :bucket_1, bucket_1_result)
  end
end
