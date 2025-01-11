defmodule SchoolKit.Attainment8.Bucket1Test do
  use ExUnit.Case, async: true
  doctest SchoolKit.Attainment8.Bucket1

  alias SchoolKit.Attainment8.Bucket1

  describe "calculate/2" do
    setup do
      subject_results = %{
        english_literature: 6,
        english_language: 7,
        maths: 8
      }

      attainment_8 = %{}

      {:ok, attainment_8: attainment_8, subject_results: subject_results}
    end

    test "calculates bucket 1 result with correct grades", %{
      attainment_8: attainment_8,
      subject_results: subject_results
    } do
      result = Bucket1.calculate(attainment_8, subject_results)

      assert result.bucket_1.english == %SchoolKit.Attainment8.Utils.SubjectGrade{
               subject_key: :english_language,
               grade: 7
             }

      assert result.bucket_1.maths == %{
               subject_key: :maths,
               grade: 8
             }

      # (7 + 8) * 2.0
      assert result.bucket_1.total == 15
    end

    test "uses the highest grade between English Literature and English Language", %{
      attainment_8: attainment_8,
      subject_results: subject_results
    } do
      subject_results =
        Map.put(subject_results, :english_language, 5)

      result = Bucket1.calculate(attainment_8, subject_results)

      assert result.bucket_1.english == %SchoolKit.Attainment8.Utils.SubjectGrade{
               subject_key: :english_literature,
               grade: 6
             }
    end

    test "handles missing grades gracefully", %{
      attainment_8: attainment_8,
      subject_results: subject_results
    } do
      subject_results = Map.delete(subject_results, :english_language)

      result = Bucket1.calculate(attainment_8, subject_results)

      assert result.bucket_1.english == %SchoolKit.Attainment8.Utils.SubjectGrade{
               subject_key: :english_literature,
               grade: 6
             }

      assert result.bucket_1.maths == %{
               subject_key: :maths,
               grade: 8
             }

      # (6 + 8) * 2.0
      assert result.bucket_1.total == 14
    end

    test "returns 0 total if no English or Maths grades are provided", %{
      attainment_8: attainment_8
    } do
      subject_results = %{}

      result = Bucket1.calculate(attainment_8, subject_results)

      assert result.bucket_1.english == %SchoolKit.Attainment8.Utils.SubjectGrade{
               subject_key: :english_literature,
               grade: nil
             }

      assert result.bucket_1.maths == %{
               subject_key: :maths,
               grade: nil
             }

      assert result.bucket_1.total == 0.0
    end
  end
end
