defmodule SchoolKit.Parser.GradeParser.NCFEL1L2VocationalParser do
  def parse(subject_key, grade) do
    calced_grade =
      case grade do
        "L2D*" -> 8.5
        "*2" -> 8.5
        "L2D" -> 7
        "D2" -> 7
        "L2M" -> 5.5
        "M2" -> 5.5
        "L2P" -> 4
        "P2" -> 4
        "L1D" -> 3
        "D1" -> 3
        "L1M" -> 2
        "M1" -> 2
        "L1P" -> 1.25
        "P1" -> 1.25
        "F" -> 0
        "U" -> 0
        "" -> nil
      end

    {subject_key, calced_grade}
  end
end
