defmodule SchoolKit.Attainment8 do
  @moduledoc """
  A students Attainment 8 shows what they managed to achieve in their
  final GCSE exam results. It is based exclusively on their exam
  results.

  The attainment 8 isn't all that useful by itself, but it feeds into
  the Progress 8 score which we will calculate after. Attainment 8 is
  also not something students will think about for themselves, but it
  helps us to compare cohorts of students, and understands a schools
  performance.

  Attainment 8 is calculated via a series of weighted buckets.
  Particular subjects fit into different buckets, and some buckets are
  weighted higher. This calculation and the subject bucket assignments
  are dictated by the DfE.

  ### Bucket 1 - English and Maths

  This is for English and Maths, and the end result is double weighted.
  Bucket 1 is calculated by taking the best grade between English
  Literature and English Language, and adding it to the grade for Maths.
  For example, a student with English Literature of 4, English Language
  of 5, and Maths of 4 will get a final Bucket 1 grade of 18. The
  English Language grade was higher, so that was doubled and added to
  Maths which was also doubled.

  The unused English grade can be re-used in Bucket 3 later on.

  ### Bucket 2 - English Baccalaureate (EBacc)

  Sciences, Computing, Geography, History, and Modern Foreign Languages
  make up the majority of the English Baccalaureate which is Bucket 2.
  The top 3 grades from across these subjects are selected, and added
  together to create the Bucket 2 result. This bucket is single weighted.

  ### Bucket 3 - Open Subjects (Vocationals)

  Vocational qualifications such as BTEC's and anything else fall into
  Bucket 3. The unused English subject from Bucket 1 is also included
  here. Like Bucket 2, we take the top three grades and add them
  together to get the final Bucket 3 result. This bucket is also single
  weighted.

  ### Total Attainment 8

  The total attainment 8 is simply calculated by adding together the
  total value from all three buckets. We also calculate a 10 subject
  average which is used in other calculations later on.
  """

  alias SchoolKit.StudentRecord
  alias SchoolKit.Attainment8.Bucket1
  alias SchoolKit.Attainment8.Bucket2
  alias SchoolKit.Attainment8.Bucket3

  def calculate_attainment_8(%StudentRecord{subject_results: subject_results} = student_record) do
    attainment_8 =
      %{}
      |> Bucket1.calculate(subject_results)
      |> Bucket2.calculate(subject_results)
      |> Bucket3.calculate(subject_results)
      |> calculate_total()

    %StudentRecord{student_record | attainment_8: attainment_8}
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
end
