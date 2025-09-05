FactoryBot.define do
  factory :analysis_result do
    verbatim_collection { nil }
    response_id { 1 }
    text { "MyText" }
    thematic_codes { "MyText" }
    sentiment { "MyString" }
    is_garbage { false }
  end
end
