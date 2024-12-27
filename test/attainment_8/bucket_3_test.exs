defmodule SchoolKit.Attainment8.Bucket3Test do
  use ExUnit.Case, async: true

  alias SchoolKit.Attainment8.Bucket3

  describe "calculate/2" do
    setup do
      attainment_8 = %{
        bucket_1: %{
          english: %{subject_key: :english_literature, grade: 7},
          maths: %{subject_key: :maths, grade: 8},
          total: 30.0
        },
        bucket_2: %{
          subject_1: %{subject_key: :history, grade: 8},
          subject_2: %{subject_key: :science_physics, grade: 9},
          subject_3: %{subject_key: :geography, grade: 7},
          total: 24.0
        }
      }

      subject_results = %{
        english_language: 6,
        science_chemistry: 8,
        science_biology: 9,
        music: 7,
        art: 6
      }

      {:ok, attainment_8: attainment_8, subject_results: subject_results}
    end

    test "calculates bucket 3 result with unused English and top open subjects", %{
      attainment_8: attainment_8,
      subject_results: subject_results
    } do
      result = Bucket3.calculate(attainment_8, subject_results)

      assert result[:bucket_3][:subject_1] == %{subject_key: :science_biology, grade: 9}
      assert result[:bucket_3][:subject_2] == %{subject_key: :science_chemistry, grade: 8}
      assert result[:bucket_3][:subject_3] == %{subject_key: :music, grade: 7}
      # 9 + 8 + 6
      assert result[:bucket_3][:total] == 24
    end

    test "handles case when no English is left over from Bucket 1", %{
      attainment_8: attainment_8,
      subject_results: subject_results
    } do
      attainment_8 =
        Map.update!(attainment_8, :bucket_1, fn bucket_1 ->
          Map.put(bucket_1, :english, %{subject_key: :english_language, grade: 6})
        end)

      result = Bucket3.calculate(attainment_8, subject_results)

      assert result[:bucket_3][:subject_1] == %{subject_key: :science_biology, grade: 9}
      assert result[:bucket_3][:subject_2] == %{subject_key: :science_chemistry, grade: 8}
      assert result[:bucket_3][:subject_3] == %{subject_key: :music, grade: 7}
      # 9 + 8 + 6
      assert result[:bucket_3][:total] == 24
    end

    test "handles fewer than three available subjects", %{
      attainment_8: attainment_8,
      subject_results: subject_results
    } do
      subject_results = Map.take(subject_results, [:science_biology])

      result = Bucket3.calculate(attainment_8, subject_results)

      assert result[:bucket_3][:subject_1] == %{subject_key: :science_biology, grade: 9}
      assert result[:bucket_3][:subject_2] == %{subject_key: :empty, grade: 0}
      assert result[:bucket_3][:subject_3] == %{subject_key: :empty, grade: 0}
      # Only science_biology grade
      assert result[:bucket_3][:total] == 9
    end

    test "returns 0 total if no subjects are available", %{attainment_8: attainment_8} do
      subject_results = %{}

      result = Bucket3.calculate(attainment_8, subject_results)

      assert result[:bucket_3][:subject_1] == %{subject_key: :empty, grade: 0}
      assert result[:bucket_3][:subject_2] == %{subject_key: :empty, grade: 0}
      assert result[:bucket_3][:subject_3] == %{subject_key: :empty, grade: 0}
      assert result[:bucket_3][:total] == 0.0
    end
  end
end
