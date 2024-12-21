defmodule SchoolKit.Parser.GradeParser do
  def parse_grade(subject, grade) do
    subject_grade_parser =
      Enum.find(subject_grade_parsers(), fn {subject_key, _subject_key_atom, _parser} ->
        subject_key == subject
      end)

    case subject_grade_parser do
      {_subject, subject_key_atom, mapper} -> mapper.(subject_key_atom, grade)
      _ -> :no_normaliser_found
    end
  end

  defp subject_grade_parsers() do
    [
      {"English Language", :english_language, &reformed_gcse_parser/2},
      {"English Literature", :english_literature, &reformed_gcse_parser/2},
      {"Maths", :maths, &reformed_gcse_parser/2},
      {"Science Sep - Biology", :science_biology, &reformed_gcse_parser/2},
      {"Science Sep - Chemistry", :science_chemistry, &reformed_gcse_parser/2},
      {"Science Sep - Physics", :science_physics, &reformed_gcse_parser/2},
      {"ICT - Computing", :ict_computing, &reformed_gcse_parser/2},
      {"Geography", :geography, &reformed_gcse_parser/2},
      {"History", :history, &reformed_gcse_parser/2},
      {"MFL - French", :mfl_french, &reformed_gcse_parser/2},
      {"MFL - German", :mfl_german, &reformed_gcse_parser/2},
      {"MFL - Spanish", :mfl_spanish, &reformed_gcse_parser/2},
      {"MFL - Chinese", :mfl_chinese, &reformed_gcse_parser/2},
      {"MFL - All Other", :mfl_other, &reformed_gcse_parser/2},
      {"Art", :art, &reformed_gcse_parser/2},
      {"Business Studies", :business_studies, &reformed_gcse_parser/2},
      {"Design & Technology", :design_and_technology, &reformed_gcse_parser/2},
      {"Drama", :drama, &reformed_gcse_parser/2},
      {"Food Preparation & Nutrition", :food_prep_and_nutrition, &reformed_gcse_parser/2},
      {"Media Studies", :media_studies, &reformed_gcse_parser/2},
      {"Music", :music, &reformed_gcse_parser/2},
      {"Photography", :photography, &reformed_gcse_parser/2},
      {"Physical Education", :physical_education, &reformed_gcse_parser/2},
      {"Religious Studies", :religious_studies, &reformed_gcse_parser/2},
      {"Textiles", :textiles, &reformed_gcse_parser/2},
      {"GCSE (Other)", :gcse_other, &reformed_gcse_parser/2},
      {"Open Subject - Ref'd GCSE 13", :open_subject_13, &reformed_gcse_parser/2},
      {"Open Subject - Ref'd GCSE 14", :open_subject_14, &reformed_gcse_parser/2},
      {"Open Subject - Ref'd GCSE 15", :open_subject_15, &reformed_gcse_parser/2},
      {"Science - Combined (Double Award)", :science_double_award,
       &science_gcse_double_award_parser/2},
      {"Music (Vocational Quals)", :music_vocational, &cambridge_national_cert_parser/2},
      {"Music Tech (Vocational Quals)", :music_tech_vocational,
       &cambridge_national_cert_parser/2},
      {"Performing Arts (Vocational Quals)", :performing_arts_vocational,
       &cambridge_national_cert_parser/2},
      {"Sport (Vocational Quals)", :sport_vocational, &cambridge_national_cert_parser/2},
      {"Travel & Tourism (Vocational Quals)", :travel_tourism_vocational,
       &cambridge_national_cert_parser/2},
      {"Child Development (Vocational Quals)", :child_development_vocational,
       &btec_l1_l2_award_parser/2},
      {"Engineering (Vocational Quals)", :engineering_vocational, &btec_l1_l2_award_parser/2},
      {"Health & Social Care (Vocational Quals)", :health_and_social_care_vocational,
       &btec_l1_l2_award_parser/2},
      {"IT / iMedia / Digital Applications (Vocatinal Quals", :it_i_media_vocational,
       &btec_l1_l2_award_parser/2},
      {"WJEC L1/2 Voc Award - Subject 2", :wjec_vocational_2, &wjec_l1_l2_vocational_parser/2},
      {"WJEC L1/2 Voc Award - Subject 3", :wjec_vocational_3, &wjec_l1_l2_vocational_parser/2},
      {"NCFE L1/2 Vcert - Subject 1", :ncfe_vocational_1, &ncfe_l1_l2_vocational_parser/2},
      {"NCFE L1/2 Vcert - Subject 2", :ncfe_vocational_2, &ncfe_l1_l2_vocational_parser/2}
    ]
  end

  defp reformed_gcse_parser(subject_key, grade) do
    calced_grade =
      case grade do
        "" ->
          nil

        "U" ->
          0

        _ ->
          {value, _} = Float.parse(grade)
          value
      end

    {subject_key, calced_grade}
  end

  defp cambridge_national_cert_parser(subject_key, grade) do
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

  defp btec_l1_l2_award_parser(subject_key, grade) do
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

  defp wjec_l1_l2_vocational_parser(subject_key, grade) do
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

  defp ncfe_l1_l2_vocational_parser(subject_key, grade) do
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

  defp science_gcse_double_award_parser(_subject_key, grade) do
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
