require 'rails_helper'

RSpec.describe "articles/index", type: :view do
  before(:each) do
    assign(:articles, [
      Article.create!(
        :user_id => "User",
        :title => "Title",
        :url => "Url",
        :content => "MyText"
      ),
      Article.create!(
        :user_id => "User",
        :title => "Title",
        :url => "Url",
        :content => "MyText"
      )
    ])
  end

  it "renders a list of articles" do
    render
    assert_select "tr>td", :text => "User".to_s, :count => 2
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "Url".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
