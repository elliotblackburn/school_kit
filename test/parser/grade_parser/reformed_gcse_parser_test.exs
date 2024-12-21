defmodule SchoolKit.Parser.GradeParser.ReformedGCSEParserTest do
  use ExUnit.Case

  alias SchoolKit.Parser.GradeParser.ReformedGCSEParser

  describe "parse/2" do
    test "returns the correct parsed grade for numeric grades" do
      assert ReformedGCSEParser.parse(:subject_name, "9") == {:subject_name, 9.0}
      assert ReformedGCSEParser.parse(:subject_name, "8.5") == {:subject_name, 8.5}
      assert ReformedGCSEParser.parse(:subject_name, "4") == {:subject_name, 4.0}
    end

    test "returns the correct parsed grade for ungraded (U)" do
      assert ReformedGCSEParser.parse(:subject_name, "U") == {:subject_name, 0}
    end

    test "returns nil for empty grade string" do
      assert ReformedGCSEParser.parse(:subject_name, "") == {:subject_name, nil}
    end

    test "raises error for invalid grades" do
      assert ReformedGCSEParser.parse(:subject_name, "Invalid") == {:subject_name, nil}
    end
  end
end
