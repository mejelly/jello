FactoryGirl.define do
  factory :translation do
    # sequence(:id) { |number| number }
    article_id 1
    user_id "mrteera"
    status false
    article_section "MyString"
    translation_section "MyString"
    user_name "Teera"
  end

  factory :translation2, class: Translation do

  end
end
