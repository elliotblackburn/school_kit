defmodule SchoolKit.Parser.StudentRecordParserTest do
  use ExUnit.Case, async: true
  alias SchoolKit.Parser.StudentRecordParser

  describe "parse_student_record/1" do
    test "parses valid input correctly" do
      record = %{
        "Surname Forename" => "Doe John",
        "School" => "Central High",
        "Gender" => "M",
        "Pupil Premium" => "Y",
        "Disadvantaged" => "N",
        "SEND" => "K",
        "Attendance Band" => "90-96%",
        "KS2 Reading Scaled Score" => "110.5",
        "KS2 Maths Scaled Score" => "120.2"
      }

      expected = %{
        name: "Doe John",
        school: "Central High",
        gender: :male,
        pupil_premium: true,
        disadvantaged: false,
        SEND: :arranged_support,
        attendance_band: "90-95%",
        ks2: %{
          reading_score: 110.5,
          maths_score: 120.2,
          average_score: 115.35
        }
      }

      assert StudentRecordParser.parse_student_record(record) == expected
    end

    test "handles case-insensitivity for gender, boolean, SEND, and attendance band" do
      record = %{
        "Gender" => "m",
        "Pupil Premium" => "y",
        "Disadvantaged" => "n",
        "SEND" => "k",
        "Attendance Band" => "96%+"
      }

      expected = %{
        gender: :male,
        pupil_premium: true,
        disadvantaged: false,
        SEND: :arranged_support,
        attendance_band: "96%+"
      }

      assert StudentRecordParser.parse_student_record(record) |> Map.take(Map.keys(expected)) ==
               expected
    end

    test "handles similar reasonable values for gender, boolean, SEND, and attendance band" do
      record = %{
        "Gender" => "male",
        "Pupil Premium" => "yes",
        "Disadvantaged" => "no",
        "SEND" => "arranged support",
        "Attendance Band" => "96%+"
      }

      expected = %{
        gender: :male,
        pupil_premium: true,
        disadvantaged: false,
        SEND: :arranged_support,
        attendance_band: "96%+"
      }

      assert StudentRecordParser.parse_student_record(record) |> Map.take(Map.keys(expected)) ==
               expected
    end

    test "returns nil for missing or empty fields" do
      record = %{
        "Gender" => "",
        "Pupil Premium" => nil,
        "Disadvantaged" => "",
        "SEND" => "",
        "Attendance Band" => nil,
        "KS2 Reading Scaled Score" => "",
        "KS2 Maths Scaled Score" => nil
      }

      expected = %{
        gender: nil,
        pupil_premium: nil,
        disadvantaged: nil,
        SEND: nil,
        attendance_band: nil,
        ks2: nil
      }

      assert StudentRecordParser.parse_student_record(record) |> Map.take(Map.keys(expected)) ==
               expected
    end

    test "parses KS2 scores to floats" do
      record = %{
        "KS2 Reading Scaled Score" => "110.5",
        "KS2 Maths Scaled Score" => "120.2"
      }

      expected = %{
        ks2: %{
          reading_score: 110.5,
          maths_score: 120.2,
          average_score: 115.35
        }
      }

      assert StudentRecordParser.parse_student_record(record) |> Map.take(Map.keys(expected)) ==
               expected
    end

    test "returns nil for invalid KS2 scores" do
      record = %{
        "KS2 Reading Scaled Score" => "abc",
        "KS2 Maths Scaled Score" => "120.2"
      }

      assert %{ks2: nil} = StudentRecordParser.parse_student_record(record)
    end

    test "returns nil for invalid attendance band" do
      record = %{
        "Attendance Band" => "INVALID"
      }

      assert %{attendance_band: nil} = StudentRecordParser.parse_student_record(record)
    end

    test "returns all nil for empty input map" do
      record = %{}

      expected = %{
        name: nil,
        school: nil,
        gender: nil,
        pupil_premium: nil,
        disadvantaged: nil,
        SEND: nil,
        attendance_band: nil,
        ks2: nil
      }

      assert StudentRecordParser.parse_student_record(record) == expected
    end
  end
end
