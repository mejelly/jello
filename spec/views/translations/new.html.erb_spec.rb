require 'rails_helper'

RSpec.describe "translations/new", type: :view do
  before(:each) do
    assign(:translation, Translation.new(
      :article => nil,
      :user_id => "MyString",
      :status => false,
      :article_section => "MyString",
      :translation_section => "MyString"
    ))
  end

  it "renders new translation form" do
    render

    assert_select "form[action=?][method=?]", translations_path, "post" do

      assert_select "input#translation_article_id[name=?]", "translation[article_id]"

      assert_select "input#translation_user_id[name=?]", "translation[user_id]"

      assert_select "input#translation_status[name=?]", "translation[status]"

      assert_select "input#translation_article_section[name=?]", "translation[article_section]"

      assert_select "input#translation_translation_section[name=?]", "translation[translation_section]"
    end
  end
end
