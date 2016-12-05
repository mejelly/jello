FactoryGirl.define do
  factory :translation, class: Translation  do
    article_id 1
    user_id "mrteera"
    status false
    article_section "MyString"
    translation_section "MyString"
    user_name "Teera"
    gist_id "4a88aaac27a90e782bb1e866ed1ab5fe"
  end

  factory :invalid_translation, class: Translation  do
    user_id "mrteera"
    status false
    article_section "MyString"
    translation_section "MyString"
    user_name "Teera"
    gist_id "123456"
  end

  factory :updated_translation, class: Translation  do
    article_id 1
    user_id "mrteera"
    status false
    article_section "MyString"
    translation_section "MyString"
    user_name "Teera"
    gist_id "123456"
  end

  factory :translation_2, class: Translation do
    article_id 2
    user_id "mrteera"
    status false
    article_section "MyString"
    translation_section "MyString"
    user_name "Teera"
    gist_id "4a88aaac27a90e782bb1e866ed1ab5fe"
  end
end
