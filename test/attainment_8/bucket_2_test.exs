defmodule SchoolKit.Attainment8.Bucket2Test do
  use ExUnit.Case, async: true
  doctest SchoolKit.Attainment8.Bucket2

  alias SchoolKit.Attainment8.Bucket2

  describe "calculate/2" do
    setup do
      subject_results = %{
        history: 8,
        geography: 7,
        science_physics: 9,
        science_chemistry: 6,
        science_biology: 5
      }

      attainment_8 = %{}

      {:ok, attainment_8: attainment_8, subject_results: subject_results}
    end

    test "calculates bucket 2 result with the top 3 EBacc grades", %{
      attainment_8: attainment_8,
      subject_results: subject_results
    } do
      result = Bucket2.calculate(attainment_8, subject_results)

      assert result[:bucket_2][:subject_1] == %{subject_key: :science_physics, grade: 9}
      assert result[:bucket_2][:subject_2] == %{subject_key: :history, grade: 8}
      assert result[:bucket_2][:subject_3] == %{subject_key: :geography, grade: 7}
      # 9 + 8 + 7
      assert result[:bucket_2][:total] == 24
    end

    test "handles less than 3 EBacc grades", %{
      attainment_8: attainment_8,
      subject_results: subject_results
    } do
      subject_results = Map.take(subject_results, [:history, :science_physics])

      result = Bucket2.calculate(attainment_8, subject_results)

      assert result[:bucket_2][:subject_1] == %{subject_key: :science_physics, grade: 9}
      assert result[:bucket_2][:subject_2] == %{subject_key: :history, grade: 8}
      assert result[:bucket_2][:subject_3] == %{subject_key: :empty, grade: 0}
      # 9 + 8
      assert result[:bucket_2][:total] == 17
    end

    test "returns 0 total if no EBacc grades are provided", %{attainment_8: attainment_8} do
      subject_results = %{}

      result = Bucket2.calculate(attainment_8, subject_results)

      assert result[:bucket_2][:subject_1] == %{subject_key: :empty, grade: 0}
      assert result[:bucket_2][:subject_2] == %{subject_key: :empty, grade: 0}
      assert result[:bucket_2][:subject_3] == %{subject_key: :empty, grade: 0}
      assert result[:bucket_2][:total] == 0.0
    end
  end
end
