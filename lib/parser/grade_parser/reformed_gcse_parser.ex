defmodule SchoolKit.Parser.GradeParser.ReformedGCSEParser do
  def parse(subject_key, grade) do
    calced_grade =
      case grade do
        "" ->
          nil

        "U" ->
          0

        _ ->
          case Float.parse(grade) do
            :error -> nil
            {value, _} -> value
          end
      end

    {subject_key, calced_grade}
  end
end
