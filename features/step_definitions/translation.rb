Given(/^I am at home page$/) do
  visit root_path
end

When(/^I login$/) do
  click_link 'Login'
  click_button 'Log in with GitHub'
  sleep 3
  fill_in 'login_field', with: ENV['GITHUB_USERNAME']
  fill_in 'password', with: ENV['GITHUB_PASSWORD']
  click_button 'Sign in'
end

When(/^I create a new article$/) do
  click_link 'New Article'
  fill_in 'article_user_id', with: 'mrteera01'
  fill_in 'article_title', with: 'This is my article'
  fill_in 'article_url', with: 'http://mejello.com'
  fill_in 'article_content', with: 'Hello, there! This is a content yay'
  click_button 'Create Article'
end

Then(/^I should see article detail$/) do
  expect(page).to have_content("Hello, there! This is a content yay")
  save_and_open_page
end
