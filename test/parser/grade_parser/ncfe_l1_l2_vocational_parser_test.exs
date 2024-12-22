defmodule SchoolKit.Parser.GradeParser.NCFEL1L2VocationalParserTest do
  use ExUnit.Case, async: true

  alias SchoolKit.Parser.GradeParser.NCFEL1L2VocationalParser

  describe "parse/2" do
    test "returns the correct parsed grade for Level 2 Distinction Star" do
      assert NCFEL1L2VocationalParser.parse(:subject_name, "L2D*") == {:subject_name, 8.5}
      assert NCFEL1L2VocationalParser.parse(:subject_name, "*2") == {:subject_name, 8.5}
    end

    test "returns the correct parsed grade for Level 2 Distinction" do
      assert NCFEL1L2VocationalParser.parse(:subject_name, "L2D") == {:subject_name, 7}
      assert NCFEL1L2VocationalParser.parse(:subject_name, "D2") == {:subject_name, 7}
    end

    test "returns the correct parsed grade for Level 2 Merit" do
      assert NCFEL1L2VocationalParser.parse(:subject_name, "L2M") == {:subject_name, 5.5}
      assert NCFEL1L2VocationalParser.parse(:subject_name, "M2") == {:subject_name, 5.5}
    end

    test "returns the correct parsed grade for Level 2 Pass" do
      assert NCFEL1L2VocationalParser.parse(:subject_name, "L2P") == {:subject_name, 4}
      assert NCFEL1L2VocationalParser.parse(:subject_name, "P2") == {:subject_name, 4}
    end

    test "returns the correct parsed grade for Level 1 Distinction" do
      assert NCFEL1L2VocationalParser.parse(:subject_name, "L1D") == {:subject_name, 3}
      assert NCFEL1L2VocationalParser.parse(:subject_name, "D1") == {:subject_name, 3}
    end

    test "returns the correct parsed grade for Level 1 Merit" do
      assert NCFEL1L2VocationalParser.parse(:subject_name, "L1M") == {:subject_name, 2}
      assert NCFEL1L2VocationalParser.parse(:subject_name, "M1") == {:subject_name, 2}
    end

    test "returns the correct parsed grade for Level 1 Pass" do
      assert NCFEL1L2VocationalParser.parse(:subject_name, "L1P") == {:subject_name, 1.25}
      assert NCFEL1L2VocationalParser.parse(:subject_name, "P1") == {:subject_name, 1.25}
    end

    test "returns the correct parsed grade for Fail or Ungraded" do
      assert NCFEL1L2VocationalParser.parse(:subject_name, "F") == {:subject_name, 0}
      assert NCFEL1L2VocationalParser.parse(:subject_name, "U") == {:subject_name, 0}
    end

    test "returns nil for empty grade string" do
      assert NCFEL1L2VocationalParser.parse(:subject_name, "") == {:subject_name, nil}
    end
  end
end
