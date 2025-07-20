Feature: Comprehensive pickle file testing scenarios

  Scenario: Basic visibility and interaction
    When I see Hello World
    Then I can see type:Text
    When I tap Click Me
    Then I settle

  Scenario: Enhanced text matching
    When I see contains:Hello
    Then I tap startsWith:Click
    When I see endsWith:World
    Then I see regex:^Hello.*World$

  Scenario: Advanced text input
    When I enter test text into type:TextField
    Then field type:TextField contains test text
    When I clear field type:TextField
    Then I do not see test text

  Scenario: Gesture interactions
    When I long press type:ElevatedButton
    Then I settle
    When I double tap type:ElevatedButton
    Then I settle
    When I swipe left on type:ListView
    Then I settle

  Scenario: Navigation and dismissal
    When I navigate back
    Then I settle
    When I dismiss dialog
    Then I do not see type:AlertDialog

  Scenario: Keyboard interactions
    When I press enter
    When I press escape
    When I press space

  Scenario: Advanced waiting and pumping
    When I wait until I see Loading Complete
    When I pump 3
    Then I see Success

  Scenario: Negative assertions with enhanced matching
    When I tap Submit
    Then I don't see contains:Error
    Then I can see startsWith:Success
