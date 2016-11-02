require 'rails_helper'

RSpec.describe "translations/show", type: :view do
  before(:each) do
    @translation = assign(:translation, Translation.create!(
      :article => nil,
      :user_id => "User",
      :status => false,
      :article_section => "Article Section",
      :translation_section => "Translation Section"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/User/)
    expect(rendered).to match(/false/)
    expect(rendered).to match(/Article Section/)
    expect(rendered).to match(/Translation Section/)
  end
end
