defmodule SchoolKit.Parser.GradeParser.ScienceGCSEDoubleAwardParserTest do
  use ExUnit.Case, async: true

  alias SchoolKit.Parser.GradeParser.ScienceGCSEDoubleAwardParser

  describe "parse/2" do
    test "returns the correct parsed grade for double awards" do
      assert ScienceGCSEDoubleAwardParser.parse(:subject_name, "99.00") == [
               {:science_double_award_1, 9.0},
               {:science_double_award_2, 9.0}
             ]

      assert ScienceGCSEDoubleAwardParser.parse(:subject_name, "87.00") == [
               {:science_double_award_1, 7.5},
               {:science_double_award_2, 7.5}
             ]

      assert ScienceGCSEDoubleAwardParser.parse(:subject_name, "65.00") == [
               {:science_double_award_1, 5.5},
               {:science_double_award_2, 5.5}
             ]
    end

    test "returns the correct parsed grade for ungraded (U)" do
      assert ScienceGCSEDoubleAwardParser.parse(:subject_name, "U") == [
               {:science_double_award_1, 0},
               {:science_double_award_2, 0}
             ]
    end

    test "returns nil for empty grade string" do
      assert ScienceGCSEDoubleAwardParser.parse(:subject_name, "") == [
               {:science_double_award_1, nil},
               {:science_double_award_2, nil}
             ]
    end

    test "handles various valid grades" do
      assert ScienceGCSEDoubleAwardParser.parse(:subject_name, "54.00") == [
               {:science_double_award_1, 4.5},
               {:science_double_award_2, 4.5}
             ]

      assert ScienceGCSEDoubleAwardParser.parse(:subject_name, "32.00") == [
               {:science_double_award_1, 2.5},
               {:science_double_award_2, 2.5}
             ]

      assert ScienceGCSEDoubleAwardParser.parse(:subject_name, "21.00") == [
               {:science_double_award_1, 1.5},
               {:science_double_award_2, 1.5}
             ]
    end
  end
end
