Feature: Custom Steps Demo

  Scenario: Using custom business logic steps
    When I setup test environment
    And I login with default credentials  
    And I navigate to shopping cart
    Then I verify cart total is correct
    When I complete checkout with default payment
    Then I verify order confirmation
    And I cleanup test data

  Scenario: Using pattern-based custom steps  
    When I wait for 500 milliseconds
    Then I verify that cart contains "Product A"
    When I wait for 2 seconds and then tap checkout_button
    Then I see Order completed successfully

  Scenario: Fallback to built-in steps
    When I see Welcome Message
    And I tap key:continue_button
    Then I do not see Loading...
