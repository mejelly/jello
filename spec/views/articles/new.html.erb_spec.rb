require 'rails_helper'

RSpec.describe "articles/new", type: :view do
  before(:each) do
    assign(:article, Article.new(
      :user_id => "MyString",
      :title => "MyString",
      :url => "MyString",
      :content => "MyText"
    ))
  end

  it "renders new article form" do
    render

    assert_select "form[action=?][method=?]", articles_path, "post" do

      assert_select "input#article_user_id[name=?]", "article[user_id]"

      assert_select "input#article_title[name=?]", "article[title]"

      assert_select "input#article_url[name=?]", "article[url]"

      assert_select "textarea#article_content[name=?]", "article[content]"
    end
  end
end
