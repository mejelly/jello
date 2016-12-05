require 'rails_helper'

RSpec.describe "translations/index", type: :view do
  # before(:each) do
  #   FactoryGirl.create(:article_1)
  #   FactoryGirl.create(:article_2)
  #   FactoryGirl.create(:translation)
  #   FactoryGirl.create(:translation_2)
  #   assign(:translations, [
  #     Translation.create!(
  #       :article_id => 1,
  #       :user_id => "User",
  #       :status => false,
  #       :article_section => "Article Section",
  #       :translation_section => "Translation Section"
  #     ),
  #     Translation.create!(
  #       :article_id => 2,
  #       :user_id => "User",
  #       :status => false,
  #       :article_section => "Article Section",
  #       :translation_section => "Translation Section"
  #     )
  #   ])
  # end
  #
  # it "renders a list of translations" do
  #   render
  #   assert_select "tr>td", :text => nil.to_s, :count => 2
  #   assert_select "tr>td", :text => "User".to_s, :count => 2
  #   assert_select "tr>td", :text => false.to_s, :count => 2
  #   assert_select "tr>td", :text => "Article Section".to_s, :count => 2
  #   assert_select "tr>td", :text => "Translation Section".to_s, :count => 2
  # end
end
