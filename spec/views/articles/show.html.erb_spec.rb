require 'rails_helper'

RSpec.describe "articles/show", type: :view do
  before(:each) do
    @article = assign(:article, Article.create!(
      :user_id => "User",
      :title => "Title",
      :url => "Url",
      :content => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/User/)
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/Url/)
    expect(rendered).to match(/MyText/)
  end
end
