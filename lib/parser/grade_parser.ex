defmodule SchoolKit.Parser.GradeParser do
  alias SchoolKit.Parser.GradeParser.ReformedGCSEParser
  alias SchoolKit.Parser.GradeParser.CambridgeNationalCertParser
  alias SchoolKit.Parser.GradeParser.BTECL1L2AwardParser
  alias SchoolKit.Parser.GradeParser.WJECL1L2VocationalParser
  alias SchoolKit.Parser.GradeParser.NCFEL1L2VocationalParser
  alias SchoolKit.Parser.GradeParser.ScienceGCSEDoubleAwardParser

  def parse_grade(subject, grade) do
    case Map.get(subject_grade_parsers(), subject) do
      nil ->
        :no_normaliser_found

      {subject_key, mapper} ->
        mapper.(subject_key, grade)
    end
  end

  def subject_grade_parsers() do
    %{
      "English Language" => {:english_language, &ReformedGCSEParser.parse/2},
      "English Literature" => {:english_literature, &ReformedGCSEParser.parse/2},
      "Maths" => {:maths, &ReformedGCSEParser.parse/2},
      "Science Sep - Biology" => {:science_biology, &ReformedGCSEParser.parse/2},
      "Science Sep - Chemistry" => {:science_chemistry, &ReformedGCSEParser.parse/2},
      "Science Sep - Physics" => {:science_physics, &ReformedGCSEParser.parse/2},
      "ICT - Computing" => {:ict_computing, &ReformedGCSEParser.parse/2},
      "Geography" => {:geography, &ReformedGCSEParser.parse/2},
      "History" => {:history, &ReformedGCSEParser.parse/2},
      "MFL - French" => {:mfl_french, &ReformedGCSEParser.parse/2},
      "MFL - German" => {:mfl_german, &ReformedGCSEParser.parse/2},
      "MFL - Spanish" => {:mfl_spanish, &ReformedGCSEParser.parse/2},
      "MFL - Chinese" => {:mfl_chinese, &ReformedGCSEParser.parse/2},
      "MFL - All Other" => {:mfl_other, &ReformedGCSEParser.parse/2},
      "Art" => {:art, &ReformedGCSEParser.parse/2},
      "Business Studies" => {:business_studies, &ReformedGCSEParser.parse/2},
      "Design & Technology" => {:design_and_technology, &ReformedGCSEParser.parse/2},
      "Drama" => {:drama, &ReformedGCSEParser.parse/2},
      "Food Preparation & Nutrition" => {:food_prep_and_nutrition, &ReformedGCSEParser.parse/2},
      "Media Studies" => {:media_studies, &ReformedGCSEParser.parse/2},
      "Music" => {:music, &ReformedGCSEParser.parse/2},
      "Photography" => {:photography, &ReformedGCSEParser.parse/2},
      "Physical Education" => {:physical_education, &ReformedGCSEParser.parse/2},
      "Religious Studies" => {:religious_studies, &ReformedGCSEParser.parse/2},
      "Textiles" => {:textiles, &ReformedGCSEParser.parse/2},
      "GCSE (Other)" => {:gcse_other, &ReformedGCSEParser.parse/2},
      "Open Subject - Ref'd GCSE 13" => {:open_subject_13, &ReformedGCSEParser.parse/2},
      "Open Subject - Ref'd GCSE 14" => {:open_subject_14, &ReformedGCSEParser.parse/2},
      "Open Subject - Ref'd GCSE 15" => {:open_subject_15, &ReformedGCSEParser.parse/2},
      "Science - Combined (Double Award)" =>
        {:science_double_award, &ScienceGCSEDoubleAwardParser.parse/2},
      "Music (Vocational Quals)" => {:music_vocational, &CambridgeNationalCertParser.parse/2},
      "Music Tech (Vocational Quals)" =>
        {:music_tech_vocational, &CambridgeNationalCertParser.parse/2},
      "Performing Arts (Vocational Quals)" =>
        {:performing_arts_vocational, &CambridgeNationalCertParser.parse/2},
      "Sport (Vocational Quals)" => {:sport_vocational, &CambridgeNationalCertParser.parse/2},
      "Travel & Tourism (Vocational Quals)" =>
        {:travel_tourism_vocational, &CambridgeNationalCertParser.parse/2},
      "Child Development (Vocational Quals)" =>
        {:child_development_vocational, &BTECL1L2AwardParser.parse/2},
      "Engineering (Vocational Quals)" => {:engineering_vocational, &BTECL1L2AwardParser.parse/2},
      "Health & Social Care (Vocational Quals)" =>
        {:health_and_social_care_vocational, &BTECL1L2AwardParser.parse/2},
      "IT / iMedia / Digital Applications (Vocatinal Quals" =>
        {:it_i_media_vocational, &BTECL1L2AwardParser.parse/2},
      "WJEC L1/2 Voc Award - Subject 2" =>
        {:wjec_vocational_2, &WJECL1L2VocationalParser.parse/2},
      "WJEC L1/2 Voc Award - Subject 3" =>
        {:wjec_vocational_3, &WJECL1L2VocationalParser.parse/2},
      "NCFE L1/2 Vcert - Subject 1" => {:ncfe_vocational_1, &NCFEL1L2VocationalParser.parse/2},
      "NCFE L1/2 Vcert - Subject 2" => {:ncfe_vocational_2, &NCFEL1L2VocationalParser.parse/2}
    }
  end
end

defmodule SchoolKit.Parser.GradeParser.ParserBehaviour do
  @callback parse(atom, String.t()) :: {atom, float | nil}
end
