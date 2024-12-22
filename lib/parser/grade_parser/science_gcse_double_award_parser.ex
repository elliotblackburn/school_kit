defmodule SchoolKit.Parser.GradeParser.ScienceGCSEDoubleAwardParser do
  @behaviour SchoolKit.Parser.GradeParser.ParserBehaviour

  def parse(_subject_key, grade) do
    # This ONLY applies to the Science double award. In this case
    # we get a double grade which represents 2 GCSE's, each with their
    # own grade. Example: 9-9 or 8-7. This comes in to us as a string
    # float, such as "99.0" or "87.0".
    # As this is a double award, it can be counted twice if necessary
    # for a given student. To do this, we add each individual grade together
    # and deliver half the grade per award. So a 87.0 would become 7.5 because
    # 8 + 7 = 15 and 15 / 2 = 7.5. This would result in award 1 getting 7.5,
    # and award 2 getting 7.5.
    # This is a bit odd, but it's how the government choose to calculate it.
    calced_grade =
      case grade do
        "99.00" -> 9.0
        "98.00" -> 8.5
        "88.00" -> 8.0
        "87.00" -> 7.5
        "77.00" -> 7.0
        "76.00" -> 6.5
        "66.00" -> 6.0
        "65.00" -> 5.5
        "55.00" -> 5.0
        "54.00" -> 4.5
        "44.00" -> 4.0
        "43.00" -> 3.5
        "33.00" -> 3.0
        "32.00" -> 2.5
        "22.00" -> 2.0
        "21.00" -> 1.5
        "11.00" -> 1.0
        "U" -> 0
        "" -> nil
      end

    [{:science_double_award_1, calced_grade}, {:science_double_award_2, calced_grade}]
  end
end
