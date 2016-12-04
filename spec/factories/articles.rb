FactoryGirl.define do
  factory :article_1, class: Article do
    id 1
    user_id "user_id_1"
    title "My Title"
    url "url.com"
    content "My content to be translated"
  end

  factory :article_2, class: Article do
    id 2
    user_id "user_id_2"
    title "My Title 2"
    url "url2.com"
    content "My content to be translated 2"
  end

  factory :invalid_article, class: Article do
  end
end
