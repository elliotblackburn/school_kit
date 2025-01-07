defmodule SchoolKit.Attainment8.Bucket3 do
  @moduledoc """
  Bucket 3 is for "open" subjects (typically vocational). It is single
  weighted, but can include the unused English subject from Bucket 1, and
  any subjects not used in Bucket 2.
  """

  alias SchoolKit.Subjects
  alias SchoolKit.Attainment8.Utils

  defmodule Bucket3Result do
    defstruct [:subject_1, :subject_2, :subject_3, :total]
  end

  def calculate(attainment_8, subject_results) do
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
          bucket_2_subject = Map.get(attainment_8.bucket_2, :"subject_#{i}")
          subject == bucket_2_subject.subject_key
        end)
      end)

    # Create full, personalised list, of bucket 3 subjects for the student
    available_bucket_3_subjects =
      Subjects.bucket_3_subjects() ++
        [remaining_english_subject] ++
        remaining_bucket_2_subjects

    {subject_1, subject_2, subject_3} =
      Utils.get_top_three_subjects(subject_results, available_bucket_3_subjects)

    bucket_3_result = %Bucket3Result{
      subject_1: subject_1,
      subject_2: subject_2,
      subject_3: subject_3,
      total: Utils.sum_bucket_grades(subject_1.grade, subject_2.grade, subject_3.grade)
    }

    Map.put(attainment_8, :bucket_3, bucket_3_result)
  end
end
