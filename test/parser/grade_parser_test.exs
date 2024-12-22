defmodule SchoolKit.Parser.GradeParserTest do
  use ExUnit.Case, async: true

  describe "parse_grade/2" do
    test "returns parsed grade for a known subject" do
      assert SchoolKit.Parser.GradeParser.parse_grade("English Language", "1.0") ==
               {:english_language, 1.0}
    end

    test "returns :no_normaliser_found for an unknown subject" do
      assert SchoolKit.Parser.GradeParser.parse_grade("Unknown Subject", "A") ==
               :no_normaliser_found
    end

    test "calls the correct parser for vocational subjects" do
      assert SchoolKit.Parser.GradeParser.parse_grade("Music (Vocational Quals)", "L2D*") ==
               {:music_vocational, 8.5}
    end
  end

  describe "subject_grade_parsers/0" do
    test "includes all expected mappings" do
      parsers = SchoolKit.Parser.GradeParser.subject_grade_parsers()

      assert Map.get(parsers, "English Language") ==
               {:english_language, &SchoolKit.Parser.GradeParser.ReformedGCSEParser.parse/2}

      assert Map.get(parsers, "Science - Combined (Double Award)") ==
               {:science_double_award,
                &SchoolKit.Parser.GradeParser.ScienceGCSEDoubleAwardParser.parse/2}
    end

    test "does not include unexpected subjects" do
      parsers = SchoolKit.Parser.GradeParser.subject_grade_parsers()

      refute Map.has_key?(parsers, "Unknown Subject")
    end
  end
end
