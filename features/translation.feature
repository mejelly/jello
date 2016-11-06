Feature: translate an article

  Scenario: Teera create an article
    Given I am at home page
    When I login
    And I create a new article
    Then I should see article detail
