Feature: translate an article

  Scenario: Teera create an article
    Given I am at home page
    When I login
    And I create a new article
    Then I should see article detail
    When He clicks on Translate This Article link
    Then He should see the content on the article
    When He translates the artice
    And Clicks on the Save Translation button
    Then The translation should be saved
