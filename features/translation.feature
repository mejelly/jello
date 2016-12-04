Feature: translate an article

  @javascript
  Scenario: Teera create an article
    Given He is at home page
    When He logs in
    And He creates a new article
    Then He should see article detail
    When He clicks on Translate This Article link
    Then He should see the content on the article
    When He translates the artice
    And Clicks on the Save Translation button
    Then The translation should be saved
    When He enters a comment message and clicks the comment button
    Then the comment must be saved
    And it should be added to the comment list