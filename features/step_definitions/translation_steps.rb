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
  sleep 1
end

When(/^I create a new article$/) do
  click_link 'New Article'
  fill_in 'article_title', with: 'This is my article'
  fill_in 'article_url', with: 'http://mejello.com'
  fill_in 'article_content', with: 'Hello, there! This is a content yay'
  click_button 'Create Article'

end

Then(/^I should see article detail$/) do
  expect(page).to have_content("Hello, there! This is a content yay")
end

When(/^He clicks on Translate This Article link$/) do
  click_on("Translate This Article")
end

Then(/^He should see the content on the article$/) do
  expect(page).to have_content("Hello, there! This is a content yay")
end

When(/^He translates the artice$/) do
  page.execute_script("$('.medium-editor-element').html('This is the translation')")
  #screenshot_and_open_image
end

When(/^Clicks on the Save Translation button$/) do
  click_on("Save Translation")
end

Then(/^The translation should be saved$/) do
  page.evaluate_script 'window.location.reload()'
  expect(page).to have_content('This is the translation')
end


