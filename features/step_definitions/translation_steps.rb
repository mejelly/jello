Given(/^He is at home page$/) do
  visit root_path
end

When(/^He logs in$/) do
  click_link 'Login'
  click_button 'Log in with GitHub'
  sleep 3
  fill_in 'login_field', with: ENV['GITHUB_USERNAME']
  fill_in 'password', with: ENV['GITHUB_PASSWORD']
  click_button 'Sign in'
  sleep 1
end

When(/^He creates a new article$/) do
  @article_1 = FactoryGirl.build :article_1
  click_link 'New Article'
  fill_in 'article_title', with: @article_1.title #'This is my article'
  fill_in 'article_url', with: @article_1.url #'http://mejello.com'
  page.execute_script("$('.medium-editor-element').html('#{@article_1.content}')")
  page.execute_script("$('#article_content').html('#{@article_1.content}')")
  click_button 'Create Article'
end

Then(/^He should see article detail$/) do
  expect(page).to have_content("#{@article_1.title}")
end

When(/^He clicks on Translate This Article link$/) do
  click_on("Translate This Article")
end

Then(/^He should see the content on the article$/) do
  expect(page).to have_content("#{@article_1.content}")
end

When(/^He translates the artice$/) do
  page.execute_script("$('.medium-editor-element').html('<p>This is the translation</p>')")
end

When(/^Clicks on the Save Translation button$/) do
  click_on("Save Translation")
  sleep 10
end

Then(/^The translation should be saved$/) do
  expect(page).to have_content('This is the translation')
end

When(/^He enters a comment message and clicks the comment button$/) do
  fill_in 'comment', with: "Test comment"
  click_on("Comment")
  sleep 10
end

Then(/^the comment must be saved$/) do
  expect(find_field('comment').value).to eq ''
end

Then(/^it should be added to the comment list$/) do
  expect(page).to have_content("Test comment")
end
