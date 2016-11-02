require 'rails_helper'

RSpec.describe "translations/index", type: :view do
  before(:each) do
    assign(:translations, [
      Translation.create!(
        :article => nil,
        :user_id => "User",
        :status => false,
        :article_section => "Article Section",
        :translation_section => "Translation Section"
      ),
      Translation.create!(
        :article => nil,
        :user_id => "User",
        :status => false,
        :article_section => "Article Section",
        :translation_section => "Translation Section"
      )
    ])
  end

  it "renders a list of translations" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "User".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => "Article Section".to_s, :count => 2
    assert_select "tr>td", :text => "Translation Section".to_s, :count => 2
  end
end
