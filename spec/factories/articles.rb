FactoryGirl.define do
  factory :article_1, class: Article do
    id 1
    user_id "MyStringXYZ"
    title "My Title"
    url "url.com"
    content "My content to be translated"
  end

end
