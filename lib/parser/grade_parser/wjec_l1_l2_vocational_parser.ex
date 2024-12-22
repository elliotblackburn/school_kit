defmodule SchoolKit.Parser.GradeParser.WJECL1L2VocationalParser do
  @behaviour SchoolKit.Parser.GradeParser.ParserBehaviour

  def parse(subject_key, grade) do
    calced_grade =
      case grade do
        "L2D*" -> 8.5
        "*2" -> 8.5
        "L2D" -> 7.0
        "D2" -> 7.0
        "L2M" -> 5.5
        "M2" -> 5.5
        "L2P" -> 4.0
        "P2" -> 4.0
        "L1D*" -> 3.0
        "*1" -> 3.0
        "L1D" -> 2.0
        "D1" -> 2.0
        "L1M" -> 1.5
        "M1" -> 1.5
        "L1P" -> 1.0
        "P1" -> 1.0
        "F" -> 0
        "U" -> 0
        "" -> nil
      end

    {subject_key, calced_grade}
  end
end
